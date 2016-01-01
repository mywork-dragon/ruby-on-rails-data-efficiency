'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService", "searchService",
  function($scope, $http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService, searchService) {

    $scope.initialPageLoadComplete = false; // shows page load spinner

    $scope.load = function() {

      $scope.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_company',
        params: {id: $routeParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        $scope.companyData = data;
        var companyApps = data.iosApps.concat(data.androidApps);
        $scope.apps = companyApps;
        $scope.numApps = companyApps.length;
        $rootScope.numApps = companyApps.length;
        $scope.queryInProgress = false;

        $scope.initialPageLoadComplete = true; // hides page load spinner

        /* Sets html title attribute */

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Page Viewed", {
            "companyId": $routeParams.id,
            "appPlatform": APP_PLATFORM,
            "companyName": $scope.companyData.name,
            "fortuneRank": $scope.companyData.fortuneRank,
            "funding": $scope.companyData.funding
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        $scope.queryInProgress = false;
      });
    };
    $scope.load();

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      var linkedinLink = "";

      if (linkedinLinkType == 'company') {
        linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.companyData.name);
      } else {
        linkedinLink = "https://www.linkedin.com/vsearch/p?keywords=" + linkedinLinkType + "&company=" + encodeURI($scope.companyData.name);
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": $scope.companyData.name,
          "companyPosition": linkedinLinkType
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink);
    };

    $scope.onAppTableAppClick = function(app) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "App on Company Page Clicked", {
          "companyName": $scope.companyData.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      $window.location.href = "#/app/" + (app.type == 'IosApp' ? 'ios' : 'android') + "/" + app.id;
    };

    $scope.addMixedSelectedTo = function(list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
        $scope.notify('add-selected-success');
        $scope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error');
      });
      $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
      }
    };

    $scope.exportContactsToCsv = function() {
      apiService.exportContactsToCsv($scope.companyContacts, $scope.companyData.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    $scope.getLastUpdatedDaysClass = function(lastUpdatedDays) {
      return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
    };

    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;
    $scope.getCompanyContacts = function(websites, filter) {
      $scope.contactsLoading = true;
      apiService.getCompanyContacts(websites, filter).success(function(data) {
        $scope.companyContacts = data.contacts;
        $scope.contactsLoading = false;
        $scope.contactsLoaded = true;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': $scope.companyData.name,
            'requestResults': data.contacts,
            'requestResultsCount': data.contacts.length,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        $scope.contactsLoading = false;
        $scope.contactsLoaded = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': $scope.companyData.name,
            'requestResultsCount': 0,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      });
    };

  }
]);
