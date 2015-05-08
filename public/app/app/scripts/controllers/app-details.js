'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", function($scope, $http, $routeParams) {
  $scope.load = function() {

    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/get_ios_app',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.appData = data;
    });
  };

  $scope.load();

  /* -------- Mixpanel Analytics Start -------- */
  mixpanel.track(
    "App Page Viewed", {
      "appid": $routeParams.id
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
