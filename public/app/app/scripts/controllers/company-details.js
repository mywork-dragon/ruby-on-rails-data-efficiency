'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", function($scope, $http, $routeParams, $window) {
  $scope.load = function() {

    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/get_company',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.companyData = data;
    });
  };

  /* LinkedIn Link Button Logic */
  $scope.onLinkedinButtonClick = function(linkedinLinkType) {
    var linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.companyData.name) + "+" + linkedinLinkType;

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

  $scope.load();

  /* -------- Mixpanel Analytics Start -------- */
  mixpanel.track(
    "Company Page Viewed", {
      "companyid": $routeParams.id
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
