'use strict';

angular.module('appApp').controller("ChartsCtrl", ["$scope", '$route', "authService", "$http", "pageTitleService", "listApiService", "apiService",
  function($scope, $route, authService, $http, pageTitleService, listApiService, apiService) {

    var chartsCtrl = this;

    chartsCtrl.loadTopApps = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/charts/top-apps'
      }).success(function(data) {
        $scope.apps = data.apps
        $scope.initialPageLoadComplete = true;
      });
    };

    chartsCtrl.loadSdks = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/charts/sdks'
      }).success(function(data) {
        $scope.sdks = data.sdks
        $scope.initialPageLoadComplete = true;
      });
    };

    $scope.clickedSdkTag = function(tag) {
      $scope.tag = tag
    }

    switch ($route.current.action) {
      case "charts.top-apps":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadTopApps()
        pageTitleService.setTitle('MightySignal - iTunes Top 200 Apps');
        mixpanel.track("Top Apps Viewed");
        break;
      case "charts.sdks":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadSdks()
        pageTitleService.setTitle('MightySignal - SDKs');
        mixpanel.track("SDKs Viewed");
        break;
    }

  }
]);
