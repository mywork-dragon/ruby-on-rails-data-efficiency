'use strict';

angular.module('appApp').controller("SdkDetailsCtrl", ["$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService",
  function($http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService) {

    var sdkDetailsCtrl = this; // same as sdkCtrl = sdkDetailsCtrl

    sdkDetailsCtrl.load = function() {

      sdkDetailsCtrl.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/sdk',
        params: {id: $routeParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        sdkDetailsCtrl.sdkData = data;
        // var companyApps = data.iosApps.concat(data.androidApps);
        var companyApps = data.androidApps;
        sdkDetailsCtrl.apps = companyApps;
        sdkDetailsCtrl.numApps = companyApps.length;
        $rootScope.numApps = companyApps.length;
        sdkDetailsCtrl.queryInProgress = false;
        /* Sets html title attribute */

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Page Viewed", {
            "companyId": $routeParams.id,
            "appPlatform": APP_PLATFORM,
            "companyName": sdkDetailsCtrl.companyData.name,
            "fortuneRank": sdkDetailsCtrl.companyData.fortuneRank,
            "funding": sdkDetailsCtrl.companyData.funding
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        sdkDetailsCtrl.queryInProgress = false;
      });
    };
    sdkDetailsCtrl.load();

    sdkDetailsCtrl.onAppTableAppClick = function(app) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "App on Company Page Clicked", {
          "companyName": sdkDetailsCtrl.companyData.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      $window.location.href = "#/app/" + (app.type == 'IosApp' ? 'ios' : 'android') + "/" + app.id;
    };

    sdkDetailsCtrl.addMixedSelectedTo = function(list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
        sdkDetailsCtrl.notify('add-selected-success');
        sdkDetailsCtrl.selectedAppsForList = [];
      }).error(function() {
        sdkDetailsCtrl.notify('add-selected-error');
      });
      sdkDetailsCtrl['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    sdkDetailsCtrl.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
      }
    };

    sdkDetailsCtrl.contactsLoading = false;
    sdkDetailsCtrl.contactsLoaded = false;
    sdkDetailsCtrl.getCompanyContacts = function(websites, filter) {
      sdkDetailsCtrl.contactsLoading = true;
      apiService.getCompanyContacts(websites, filter).success(function(data) {
        sdkDetailsCtrl.companyContacts = data.contacts;
        sdkDetailsCtrl.contactsLoading = false;
        sdkDetailsCtrl.contactsLoaded = true;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': sdkDetailsCtrl.companyData.name,
            'requestResults': data.contacts,
            'requestResultsCount': data.contacts.length,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        sdkDetailsCtrl.contactsLoading = false;
        sdkDetailsCtrl.contactsLoaded = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': sdkDetailsCtrl.companyData.name,
            'requestResultsCount': 0,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      });
    };

  }
]);
