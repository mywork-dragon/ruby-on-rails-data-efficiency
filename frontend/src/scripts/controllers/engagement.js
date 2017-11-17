'use strict';

angular.module('appApp').controller("EngagementCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'slacktivity', 'searchService', 'sdkLiveScanService', 'authToken', '$location', '$rootScope',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, slacktivity, searchService, sdkLiveScanService, authToken, $location, $rootScope) {

    $scope.load = function () {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/ad_intelligence.json',
        params: {pageNum: $scope.currentPage, orderBy: $scope.order, sortBy: $scope.category}
      }).success(function(data) {
        $scope.apps = data.results;
        $scope.numApps = data.resultsCount;
        $rootScope.numApps = data.resultsCount;
        $scope.currentPage = data.pageNum;
        $rootScope.currentPage = data.pageNum;
        $scope.isLoading = false;
        adIntelligenceCtrl.updateCSVUrl();
      });
    }
  }
]);
