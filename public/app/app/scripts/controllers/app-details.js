'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", function($scope, $http, $routeParams, $window) {

  $scope.load = function() {

    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.appData = data;
    });
  };

  /* LinkedIn Link Button Logic */
  $scope.onLinkedinButtonClick = function(linkedinLinkType) {
    var linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.appData.company.name) + "+" + linkedinLinkType;

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

  $scope.load();

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
