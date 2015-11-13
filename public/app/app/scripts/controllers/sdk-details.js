'use strict';

angular.module('appApp').controller("SdkDetailsCtrl", ["$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService",
  function($http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService) {

    var sdkDetailsCtrl = this; // same as sdkCtrl = sdkDetailsCtrl

    var sdkPlatform = $routeParams.platform;

    sdkDetailsCtrl.load = function() {

      sdkDetailsCtrl.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/sdk',
        params: {id: $routeParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        sdkDetailsCtrl.sdkData = data;
        sdkDetailsCtrl.queryInProgress = false;
        /* Sets html title attribute */

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Page Viewed", {
            "sdkName": sdkDetailsCtrl.name
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
        "SDK Page Clicked", {
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

    sdkDetailsCtrl.submitSdkQuery = function() {
      var path = API_URI_BASE + "app/app#/search?app=%7B%22sdkNames%22:%5B%7B%22id%22:" + sdkDetailsCtrl.sdkData.id + ",%22name%22:%22" + encodeURI(sdkDetailsCtrl.sdkData.name) + "%22%7D%5D%7D&company=%7B%7D&custom=%7B%7D&pageNum=1&pageSize=100&platform=%7B%22appPlatform%22:%22android%22%7D";
      $window.location.href = path;
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
