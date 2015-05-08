'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", function($scope, $http, $routeParams) {
  $scope.load = function() {

    return $http({
      method: 'POST',
      url: 'http://mightysignal.com/api/get_company',
      // url: 'http://localhost:3000/api/get_company',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.companyData = data;
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
    "Company Page Viewed", {
      "companyid": $routeParams.id
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
