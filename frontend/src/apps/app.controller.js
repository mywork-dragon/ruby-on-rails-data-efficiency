import angular from 'angular';
import mixpanel from 'mixpanel-browser';
import _ from 'lodash';

import '../components/export-permissions/export-permissions.directive'; // gross
import '../components/list-create/list-create.directive'; // gross

(function() {
  'use strict';

  angular
    .module('appApp')
    .controller('AppController', AppController);

  AppController.$inject = [
    'appService',
    '$state',
    '$stateParams',
    'loggitService',
    'newsfeedService',
    'listApiService',
    'contactService',
    'pageTitleService',
    'sdkLiveScanService',
    '$rootScope',
    '$sce',
    '$window',
    'authService',
    '$auth',
    'authToken',
    '$timeout',
    '$scope'
  ];

  function AppController (
    appService,
    $state,
    $stateParams,
    loggitService,
    newsfeedService,
    listApiService,
    contactService,
    pageTitleService,
    sdkLiveScanService,
    $rootScope,
    $sce,
    $window,
    authService,
    $auth,
    authToken,
    $timeout,
    $scope
  ) {
    var app = this;

    app.activeCreative = {};
    app.activeSlide = 0;
    app.facebookAds = [];
    app.appFetchComplete = false;
    app.contactFetchComplete = false;
    app.tableCreatives = [];
    app.currentContactsPage = 1;
    app.currentCreativesPage = 1;
    app.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class=\"fa fa-external-link\"></span>')
    app.noWrapSlides = false;
    app.slideInterval = 0;
    app.tabs = [
      { title: 'General Information', index: 0, route: 'app.info' },
      { title: $sce.trustAsHtml('Ad Intelligence <span style="color:#1EAD4F;font-weight:bold">NEW</span>'), index: 1, route: 'app.ad-intelligence'}
    ]
    app.userInfo = {}

    // Bound Functions
    app.addToList = addToList;
    app.authenticateSalesforce = authenticateSalesforce;
    app.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    app.changeActiveCreative = changeActiveCreative;
    app.exportContactsToCsv = exportContactsToCsv;
    app.followApp = followApp;
    app.getCompanyContacts = getCompanyContacts;
    app.getContactEmail = getContactEmail;
    app.handleTagButtonClick = handleTagButtonClick;
    app.onLinkedinButtonClick = onLinkedinButtonClick;
    app.openAppStorePage = openAppStorePage;
    app.populateCreativesTable = populateCreativesTable;
    app.resetAppData = resetAppData;
    app.trackCompanyContactsRequest = trackCompanyContactsRequest;
    app.trackCopiedEmail = trackCopiedEmail;
    app.trackCrunchbaseClick = trackCrunchbaseClick;
    app.trackLinkedinContactClick = trackLinkedinContactClick;
    app.trackSalesforceModalOpen = trackSalesforceModalOpen;

    activate();

    function activate() {
      getApp()
        .then(function() {
          getCompanyContacts()
          addAdIds()
          getSalesforceData()
          populateCreativesTable();
          app.activeCreative = app.facebookAds[0]
          pageTitleService.setTitle(app.name)

          var eventName;

          if ($stateParams.utm_source == 'ewok') {
            eventName = "Ewok App Page Viewed"
          } else if ($stateParams.utm_source == 'salesforce') {
            eventName = "Salesforce App Page Viewed"
          } else {
            eventName = "App Page Viewed"
          }

          return eventName;
        })
        .then(function (name) {
          mixpanel.track(name, {
            "appId": app.id,
            "appName": app.name,
            "companyName": app.publisher.name,
            "appPlatform": app.platform
          })
        })
    }

    function addAdIds () {
      if (app.facebookAds) {
        for (var i = 0; i < app.facebookAds.length; i++) {
          var ad = app.facebookAds[i];
          ad.id = i;
        }
      }
    }

    function addToList (list) {
      var selectedApp = [{
        id: app.id,
        type: app.platform
      }];
      listApiService.addSelectedTo(list, selectedApp, app.platform)
        .success(function() {
          loggitService.logSuccess('App was added to list successfully.')
          $rootScope.selectedAppsForList = [];
        }).error(function() {
          loggitService.logError('Error! Something went wrong while adding to list.')
        });
      $rootScope['addSelectedToDropdown'] = "";
    }

    function authenticateSalesforce (provider) {
      $auth.authenticate(provider, { token: authToken.get() })
      .then(function(response) {
        app.sfUserConnected = true
        getSalesforceData();
      })
      .catch(function(response) {
        app.sfUserConnected = false
        alert(response.data.error)
      });
    };

    function changeActiveCreative (ad) {
      app.activeCreative = ad;
      app.activeSlide = ad.id;
    }

    function exportContactsToCsv (filter) {
      contactService.exportContactsToCsv(app.platform, app.publisher.id, filter, app.publisher.name)
        .then(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    }

    function followApp (id, action) {
      const follow = {
        id,
        type: app.platform == 'ios' ? 'IosApp' : 'AndroidApp',
        name: app.name,
        action,
        source: 'appDetails'
      }
      newsfeedService.follow(follow)
        .success(function(data) {
          app.following = data.is_following
          if (data.is_following) {
            loggitService.logSuccess('You will now see updates for this app on your Timeline')
          } else {
            loggitService.log('You will stop seeing updates for this app on your Timeline')
          }
        });
    }

    function getApp () {
      return appService.getApp($stateParams.platform, $stateParams.id)
        .then(function(data) {
          for (var value in data) {
            if (data.hasOwnProperty(value)) {
              app[value] = data[value]
            }
          }
          app.appFetchComplete = true;
        })
    }

    function getCompanyContacts (filter) {
      app.contactFetchComplete = false;
      contactService.getCompanyContacts(app.platform, app.publisher.id, filter, app.currentContactsPage)
        .then(function(data) {
          app.contacts = data.contacts;
          app.contactsCount = data.contactsCount;
          app.contactFetchComplete = true;
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

    function getSalesforceData () {
      authService.userInfo()
        .success(function(data) {
          app.userInfo.email = data.email;
          app.userInfo.salesforceName = data.salesforce_name;
          app.userInfo.salesforceImageUrl = data.salesforce_image_url;
        })
    }

    function handleTagButtonClick () {
      appService.tagAsMajorApp(app.id, app.platform)
        .then(function(data) {
          app.isMajorApp = data.isMajorApp
        })
    }

    function onLinkedinButtonClick (linkType) {
      if (linkType == 'company' && app.publisher.linkedin) {
        contactService.goToLinkedIn('linkedin', app.publisher.linkedin, 'app');
      } else {
        contactService.goToLinkedIn(linkType, app.publisher.name, 'app');
      }
    }

    function openAppStorePage () {
      const page = app.platform == 'ios' ? app.appStoreLink : 'https://play.google.com/store/apps/details?id=' + app.appIdentifier
      $window.open(page)
    }

    function populateCreativesTable () {
      const start = (app.currentCreativesPage - 1) * 10;
      const end = start + 10;
      app.tableCreatives = app.facebookAds.slice(start, end);
      app.activeSlide = start;
      app.activeCreative = app.facebookAds[start]
    }

    function resetAppData () {
      loggitService.log("Resetting app data. The page will refresh shortly.")
      appService.resetAppData(app.id)
        .then(function() {
          $timeout(function() {
            $state.reload();
          }, 5000)
        });
    }

    function setUpSalesforce () {
      authService.accountInfo()
        .success(function(data) {
          app.salesforceSettings = data.salesforce_settings
        })
    }

    function trackCompanyContactsRequest (filter) {
      mixpanel.track(
        "Company Contacts Requested", {
          'companyName': app.publisher.name,
          'requestResultsCount': app.publisher.contactsCount,
          'titleFilter': filter || '',
          'Source Type': 'app'
        }
      );
    }

    function trackCopiedEmail (contact) {
      mixpanel.track("Email Copied", {
        "Email": contact.email,
        "Company": app.publisher.name,
        "Name": contact.fullName,
        "Title": contact.title,
        "Source Type": 'publisher'
      })
    }

    function trackCrunchbaseClick () {
      contactService.trackCrunchbaseClick(app.publisher.name, 'app')
    }

    function trackLinkedinContactClick (contact) { // fixed
      contactService.trackLinkedinContactClick(contact, 'app')
    }

    function trackSalesforceModalOpen () {
      mixpanel.track(
        "Opened Salesforce Export Modal", {
          "appId": app.id,
          "appName": app.name,
          "companyName": app.publisher.name,
          "appPlatform": app.platform
        }
      );
    }

    $scope.$watch('app.activeSlide', function(newId, oldId) {
      if (app.facebookAds.length) {
        const isInTable = _.any(app.tableCreatives, ad => ad.id == newId)
        if (!isInTable) {
          app.currentCreativesPage = Math.ceil((newId + 1)/10)
          populateCreativesTable()
        }
        changeActiveCreative(app.facebookAds[newId])
      }
    })
  }
})();
