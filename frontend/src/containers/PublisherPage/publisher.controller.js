import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import 'components/export-permissions/export-permissions.directive';
import 'AngularMixpanel/publisher.mixpanel.service';
import 'AngularService/publisher.service';
import 'AngularService/ad-intelligence.service';
import 'components/ad-intel-tab/ad-intel-tab.directive';

import { attachGetCompanyContactsLoader } from 'utils/contact.utils';

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
  'uniqueStringsFilter',
  'csvUtils',
  'adIntelService',
  'publisherMixpanelService',
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
  uniqueStringsFilter,
  csvUtils,
  adIntelService,
  publisherMixpanelService,
) {
  const publisher = this;

  publisher.appFetchComplete = false;
  publisher.apps = [];
  publisher.companyContactFilter = '';
  publisher.contactFetchComplete = false;
  publisher.currentContactsPage = 1;
  publisher.currentAppPage = 1;
  publisher.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class="fa fa-external-link"></span>');
  publisher.publisherFetchComplete = false;
  publisher.rowSort = '';
  publisher.sdkFetchComplete = false;
  publisher.tabs = [
    { title: 'General Information', index: 0, route: 'publisher.info' },
    {
      title: $sce.trustAsHtml('Ad Intelligence <span style="color:#1EAD4F;font-weight:bold">NEW</span>'),
      index: 1,
      route: 'publisher.ad-intelligence',
    },
  ];


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
  publisher.trackAppClick = publisherMixpanelService.trackAppClick;
  publisher.trackCompanyContactsRequest = publisherMixpanelService.trackCompanyContactsRequest;
  publisher.trackCopiedEmail = publisherMixpanelService.trackCopiedEmail;
  publisher.trackCrunchbaseClick = publisherMixpanelService.trackCrunchbaseClick;
  publisher.trackTabClick = publisherMixpanelService.trackTabClick;

  activate();

  function activate() {
    getPublisher()
      .then(() => {
        publisher.platform = $stateParams.platform;
        publisher.id = $stateParams.id;
        pageTitleService.setTitle(publisher.name);
        publisherMixpanelService.trackPublisherPageView(publisher);
      });
    getPublisherApps();
    getPublisherSdks();
    getCompanyContacts();
  }

  function addAppsToList (list, selectedApps) {
    listApiService.addSelectedTo(list, selectedApps)
      .success(() => {
        loggitService.logSuccess('Items were added successfully.');
        publisher.selectedAppsForList = [];
      }).error(() => {
        loggitService.logError('Error! Something went wrong while adding to list.');
      });
    publisher.addSelectedToDropdown = '';
  }

  function exportContactsToCsv (filter) {
    contactService.exportContactsToCsv(publisher.platform, publisher.id, filter, publisher.name)
      .then((content) => {
        csvUtils.downloadCsv(content, 'contacts');
      });
  }

  function getCompanyContacts (filter) {
    attachGetCompanyContactsLoader(
      publisher,
      contactService.getCompanyContacts($stateParams.platform, $stateParams.id, filter, publisher.currentContactsPage)
      )
  }

  function getContactEmail (contact) {
    contact.isLoading = true;
    const clearbitId = contact.clearbitId;
    contactService.getContactEmail(clearbitId)
      .then((data) => {
        mixpanel.track('Contact Email Requested', {
          email: data.email,
          clearbitId,
        });
        contact.email = data.email;
        contact.isLoading = false;
      });
  }

  function getLastUpdatedDaysClass (lastUpdatedDays) {
    return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
  }

  function getPublisher () {
    return publisherService.getPublisher($stateParams.platform, $stateParams.id)
      .then((data) => {
        for (const value in data) {
          if (data.hasOwnProperty(value)) {
            publisher[value] = data[value];
          }
        }
        $rootScope.numApps = data.numApps;

        publisher.publisherFetchComplete = true;
      });
  }

  function getPublisherApps (category, order) {
    publisher.appFetchComplete = false;
    return publisherService.getPublisherApps($stateParams.platform, $stateParams.id, category, order, publisher.currentAppPage)
      .then((data) => {
        publisher.appFetchComplete = true;
        publisher.apps = data.apps;
        if (publisher.numApps > 0 && publisher.websites && publisher.apps[0].supportDesk) {
          publisher.websites.push(publisher.apps[0].supportDesk);
        }
        publisher.websites = uniqueStringsFilter(publisher.websites);
      });
  }

  function getPublisherSdks () {
    publisher.sdkFetchComplete = false;
    return publisherService.getPublisherSdks($stateParams.platform, $stateParams.id)
      .then((data) => {
        publisher.installedSdks = data.installed_sdks;
        publisher.uninstalledSdks = data.uninstalled_sdks;
        publisher.installedSdkCategories = publisherService.getSdkCategories(data.installed_sdks);
        publisher.uninstalledSdkCategories = publisherService.getSdkCategories(data.uninstalled_sdks);
        publisher.installedSdksCount = publisherService.getSdkCount(data.installed_sdks);
        publisher.uninstalledSdksCount = publisherService.getSdkCount(data.uninstalled_sdks);
        publisher.sdkFetchComplete = true;
      });
  }

  function handleTagButtonClick () {
    if (publisher.isMajorPublisher) {
      publisherService.untagAsMajorPublisher(publisher.id, publisher.platform)
        .then((data) => {
          loggitService.log('Publisher untagged successfully.');
          publisher.isMajorPublisher = data.isMajorPublisher;
        });
    } else {
      publisherService.tagAsMajorPublisher(publisher.id, publisher.platform)
        .then((data) => {
          loggitService.logSuccess('Publisher tagged successfully.');
          publisher.isMajorPublisher = data.isMajorPublisher;
        });
    }
  }

  function onLinkedinButtonClick (linkType) {
    contactService.goToLinkedIn(linkType, publisher.name, 'publisher');
  }

  function sortApps (category, order) {
    getPublisherApps(category, order);
    const sign = order === 'desc' ? '-' : '';
    publisher.rowSort = sign + category;
  }
}
