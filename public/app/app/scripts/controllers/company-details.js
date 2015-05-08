'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", function($scope, $http, $routeParams) {
  $scope.load = function() {

    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/get_company',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.companyData = data;
    });
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
