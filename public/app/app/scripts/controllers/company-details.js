'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService",
  function($scope, $http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService) {

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
        /* Sets html title attribute */
      }).error(function() {
        $scope.queryInProgress = false;
      });
    };
    $scope.load();


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

      $window.open(linkedinLink, '_blank');
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

    $scope.getCompanyContacts = function(companyId) {
      apiService.getCompanyContacts(companyId).success(function() {

      });
    };

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "Page Viewed", {
        "pageType": "Company",
        "companyid": $routeParams.id,
        "appPlatform": APP_PLATFORM
      }
    );
    /* -------- Mixpanel Analytics End -------- */

  }
]);
