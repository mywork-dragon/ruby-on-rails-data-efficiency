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

  $scope.load();

  mixpanel.track(
    "Company Page Viewed", {
      "companyid": $routeParams.id
    }
  );
}
]);
