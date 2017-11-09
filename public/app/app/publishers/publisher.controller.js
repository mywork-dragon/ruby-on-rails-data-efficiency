(function() {
  'use strict';

  angular
    .module('appApp')
    .controller('PublisherController', PublisherController);

  PublisherController.$inject = [
    'publisherService',
    'loggitService',
    'contactService',
    'listApiService',
    'searchService',
    'pageTitleService',
    '$state',
    '$stateParams',
    '$rootScope',
    '$sce',
    'uniqueStringsFilter'
  ];

  function PublisherController (
    publisherService,
    loggitService,
    contactService,
    listApiService,
    searchService,
    pageTitleService,
    $state,
    $stateParams,
    $rootScope,
    $sce,
    uniqueStringsFilter
  ) {
    var publisher = this;

    publisher.appFetchComplete = false;
    publisher.apps = []
    publisher.contactFetchComplete = false;
    publisher.currentContactsPage = 1;
    publisher.currentAppPage = 1;
    publisher.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class=\"fa fa-external-link\"></span>')
    publisher.publisherFetchComplete = false;
    publisher.rowSort = '';
    publisher.sdkFetchComplete = false;
    publisher.tabs = [
      { title: 'General Information', index: 0, route: 'publisher.info' },
      { title: 'Ad Intelligence', index: 1, route: 'publisher.ad-intelligence'}
    ]

    // Bound Functions
    publisher.addAppsToList = addAppsToList;
    publisher.exportContactsToCsv = exportContactsToCsv;
    publisher.getCompanyContacts = getCompanyContacts;
    publisher.getContactEmail = getContactEmail;
    publisher.getLastUpdatedDaysClass = getLastUpdatedDaysClass;
    publisher.getPublisherApps = getPublisherApps;
    publisher.handleTagButtonClick = handleTagButtonClick;
    publisher.onLinkedinButtonClick = onLinkedinButtonClick;
    publisher.sortApps = sortApps;
    publisher.trackAppClick = trackAppClick;
    publisher.trackCompanyContactsRequest = trackCompanyContactsRequest;
    publisher.trackCopiedEmail = trackCopiedEmail;
    publisher.trackCrunchbaseClick = trackCrunchbaseClick;

    activate();

    function activate() {
      getPublisher()
        .then(function() {
          publisher.platform = $stateParams.platform;
          pageTitleService.setTitle(publisher.name)

          return $stateParams.utm_source == 'salesforce' ? "Salesforce Publisher Page Viewed" : "Publisher Page Viewed"
        })
        .then(function(name) {
          mixpanel.track(name, {
            "publisherId": publisher.id,
            "appPlatform": publisher.platform,
            "publisherName": publisher.name
          })
        })
      getPublisherApps()
      getPublisherSdks()
      getCompanyContacts()
    }

    function addAppsToList (list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps)
        .success(function() {
          loggitService.logSuccess('Items were added successfully.')
          publisher.selectedAppsForList = [];
        }).error(function() {
          loggitService.logError('Error! Something went wrong while adding to list.')
        });
      publisher.addSelectedToDropdown = "";
    }

    function exportContactsToCsv (filter) {
      contactService.exportContactsToCsv(publisher.platform, publisher.id, filter, publisher.name)
        .then(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    }

    function getCompanyContacts (filter) {
      publisher.contactFetchComplete = false;
      contactService.getCompanyContacts($stateParams.platform, $stateParams.id, filter, publisher.currentContactsPage)
        .then(function(data) {
          publisher.contacts = data.contacts;
          publisher.contactsCount = data.contactsCount;
          publisher.contactFetchComplete = true;
        })
    }

    function getContactEmail (contact) {
      contact.isLoading = true
      var clearbitId = contact.clearbitId
      contactService.getContactEmail(clearbitId)
        .then(function(data) {
          mixpanel.track(
            "Contact Email Requested", {
              'email': data.email,
              'clearbitId': clearbitId
            }
          );
          contact.email = data.email
          contact.isLoading = false
        })
    }

    function getLastUpdatedDaysClass (lastUpdatedDays) {
      return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
    }

    function getPublisher () {
      return publisherService.getPublisher($stateParams.platform, $stateParams.id)
        .then(function(data) {
          for (var value in data) {
            if (data.hasOwnProperty(value)) {
              publisher[value] = data[value]
            }
          }
          $rootScope.numApps = data.numApps;

          publisher.publisherFetchComplete = true;
        })
    }

    function getPublisherApps (category, order) {
      publisher.appFetchComplete = false;
      return publisherService.getPublisherApps($stateParams.platform, $stateParams.id, category, order, publisher.currentAppPage)
        .then(function(data) {
          publisher.appFetchComplete = true;
          publisher.apps = data.apps;
          if (publisher.numApps > 0 && publisher.websites && publisher.apps[0].supportDesk) {
            publisher.websites.push(publisher.apps[0].supportDesk)
          }
          publisher.websites = uniqueStringsFilter(publisher.websites)
        })
    }

    function getPublisherSdks () {
      publisher.sdkFetchComplete = false;
      return publisherService.getPublisherSdks($stateParams.platform, $stateParams.id)
        .then(function(data) {
          publisher.installedSdks = data.installed_sdks
          publisher.uninstalledSdks = data.uninstalled_sdks
          publisher.installedSdkCategories = publisherService.getSdkCategories(data.installed_sdks)
          publisher.uninstalledSdkCategories = publisherService.getSdkCategories(data.uninstalled_sdks)
          publisher.installedSdksCount = publisherService.getSdkCount(data.installed_sdks)
          publisher.uninstalledSdksCount = publisherService.getSdkCount(data.uninstalled_sdks)
          publisher.sdkFetchComplete = true;
        })
    }

    function handleTagButtonClick () {
      if (publisher.isMajorPublisher) {
        publisherService.untagAsMajorPublisher(publisher.id, publisher.platform)
          .then(function(data) {
            loggitService.log('Publisher untagged successfully.')
            publisher.isMajorPublisher = data.isMajorPublisher
          })
      } else {
        publisherService.tagAsMajorPublisher(publisher.id, publisher.platform)
          .then(function(data) {
            loggitService.logSuccess('Publisher tagged successfully.')
            publisher.isMajorPublisher = data.isMajorPublisher
          })
      }
    }

    function onLinkedinButtonClick (linkType) {
      if (linkType == 'company' && publisher.linkedin) {
        contactService.goToLinkedIn('linkedin', publisher.linkedin, 'publisher');
      } else {
        contactService.goToLinkedIn(linkType, publisher.name, 'publisher');
      }
    }

    function sortApps (category, order) {
      getPublisherApps(category, order);
      var sign = order == 'desc' ? '-' : ''
      publisher.rowSort = sign + category;
    }

    function trackAppClick (app) {
      mixpanel.track(
        "App on Company Page Clicked", {
          "companyName": publisher.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
    }

    function trackCompanyContactsRequest (filter) {
      mixpanel.track(
        "Company Contacts Requested", {
          'companyName': publisher.name,
          'requestResultsCount': publisher.contactsCount,
          'titleFilter': filter || '',
          'Source Type': 'publisher'
        }
      );
    }

    function trackCopiedEmail (contact) {
      mixpanel.track("Email Copied", {
        "Email": contact.email,
        "Company": publisher.name,
        "Name": contact.fullName,
        "Title": contact.title,
        "Source Type": 'publisher'
      })
    }

    function trackCrunchbaseClick () {
      contactService.trackCrunchbaseClick(publisher.name, 'publisher')
    }

    function trackLinkedinContactClick () {
      contactService.trackLinkedinContactClick(contact, 'publisher')
    }
  }
})();
