import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import './appMixpanel.service.js';

import '../components/export-permissions/export-permissions.directive'; // gross
import '../components/list-create/list-create.directive'; // gross
import '../components/ad-intelligence/creative-gallery/gallery.utils' // gross?

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
    '$scope',
    'appMixpanelService',
    'galleryUtils',
    'csvUtils',
    'adIntelService'
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
    $scope,
    appMixpanelService,
    galleryUtils,
    csvUtils,
    adIntelService
  ) {
    var app = this;

    app.activeSlide = 0;
    app.appFetchComplete = false;
    app.companyContactFilter = "";
    app.contactFetchComplete = false;
    app.currentContactsPage = 1;
    app.facebookOnly = true;
    app.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class=\"fa fa-external-link\"></span>')
    app.tabs = [
      { title: 'General Information', index: 0, route: 'app.info' },
      {
        title: $sce.trustAsHtml('Ad Intelligence <span style="color:#1EAD4F;font-weight:bold">NEW</span>'),
        index: 1,
        route: 'app.ad-intelligence'
      }
    ]
    app.userInfo = {}

    // Bound Functions
    app.addToList = addToList;
    app.authenticateSalesforce = authenticateSalesforce;
    app.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    app.exportContactsToCsv = exportContactsToCsv;
    app.followApp = followApp;
    app.getCompanyContacts = getCompanyContacts;
    app.getContactEmail = getContactEmail;
    app.handleTagButtonClick = handleTagButtonClick;
    app.onLinkedinButtonClick = onLinkedinButtonClick;
    app.openAppStorePage = openAppStorePage;
    app.resetAppData = resetAppData;
    app.trackCompanyContactsRequest = appMixpanelService.trackCompanyContactsRequest;
    app.trackCopiedEmail = appMixpanelService.trackCopiedEmail;
    app.trackCrunchbaseClick = appMixpanelService.trackCrunchbaseClick;
    app.trackLinkedinContactClick = appMixpanelService.trackLinkedinContactClick;
    app.trackSalesforceModalOpen = appMixpanelService.trackSalesforceModalOpen;
    app.trackTabClick = appMixpanelService.trackTabClick;

    activate();

    function activate() {
      adIntelService.getAdSources().then(data => {
        const adSources = Object.keys(data)
        app.facebookOnly = adSources.length == 1 && adSources[0] == 'facebook'
      })
      getApp()
        .then(function() {
          getCompanyContacts()
          getSalesforceData()
          setUpSalesforce()
          pageTitleService.setTitle(app.name)
          appMixpanelService.trackAppPageView(app)
        })
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
        $scope.sfUserConnected = true
        getSalesforceData();
      })
      .catch(function(response) {
        $scope.sfUserConnected = false
        alert(response.data.error)
      });
    };

    function exportContactsToCsv (filter) {
      contactService.exportContactsToCsv(app.platform, app.publisher.id, filter, app.publisher.name)
        .then(function (content) {
          csvUtils.downloadCsv(content, 'contacts')
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
          Object.assign(app, data)
          app.facebookAds = galleryUtils.addAdIds(data.facebookAds)
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
          appMixpanelService.trackEmailRequest(data.email, clearbitId)
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
  }
})();
