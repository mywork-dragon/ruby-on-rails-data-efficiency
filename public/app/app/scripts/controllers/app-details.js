'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService) {

  $scope.load = function() {

    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.appData = data;

      /* Sets html title attribute */
      pageTitleService.setTitle($scope.appData.name);
    });
  };

  $scope.appPlatform = $routeParams.platform;

  /* LinkedIn Link Button Logic */
  $scope.onLinkedinButtonClick = function(linkedinLinkType) {
    var linkedinLink = "";

    if (linkedinLinkType == 'company') {
      linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.appData.company.name);
    } else {
      linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.appData.company.name) + "+" + linkedinLinkType;
    }

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "LinkedIn Link Clicked", {
        "companyName": $scope.appData.company.name,
        "companyPosition": linkedinLinkType
      }
    );
    /* -------- Mixpanel Analytics End -------- */

    $window.open(linkedinLink, '_blank');
  };

  $scope.linkTo = function(path) {
    $window.location.href = path;
  };

  $scope.addSelectedTo = function(list) {
    var selectedApp = [{
      id: $routeParams.id,
      type: $routeParams.platform == 'IosApp' ? 'ios' : 'android'
    }];
    listApiService.addSelectedTo(list, selectedApp, $scope.appPlatform).success(function() {
      $scope.notify('add-selected-success');
      $rootScope.selectedAppsForList = [];
    }).error(function() {
      $scope.notify('add-selected-error');
    });
    $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
  };

  $scope.notify = function(type) {
    switch (type) {
      case "add-selected-success":
        return loggitService.logSuccess("Items were added successfully.");
      case "add-selected-error":
        return loggitService.logError("Error! Something went wrong while adding to list.");
    }
  };

  $scope.load();

  $scope.contactsLoading = false;
  $scope.contactsLoaded = false;

  $scope.getCompanyContacts = function(websites) {

    $scope.contactsLoading = true;
    apiService.getCompanyContacts(websites).success(function(data) {
      $scope.companyContacts = data.contacts;
      $scope.contactsLoading = false;
      $scope.contactsLoaded = true;
    }).error(function() {
      $scope.contactsLoading = false;
      $scope.contactsLoaded = false;
    });
  };

  /* -------- Mixpanel Analytics Start -------- */
  mixpanel.track(
    "Page Viewed", {
      "pageType": "App",
      "appid": $routeParams.id,
      "appPlatform": APP_PLATFORM
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
