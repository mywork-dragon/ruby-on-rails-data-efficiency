'use strict';

angular.module('appApp').controller("AdIntelligenceCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'slacktivity', 'searchService', 'sdkLiveScanService', 'authToken', '$location', '$rootScope', 'AppPlatform',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, slacktivity, searchService, sdkLiveScanService, authToken, $location, $rootScope, AppPlatform) {

    var adIntelligenceCtrl = this;
    $scope.currentPage = 1;
    $scope.order = 'desc';
    $scope.category = 'first_seen_ads'
    $scope.rowSort = '-first_seen_ads'
    $scope.appPlatform = AppPlatform;

    // Sets html title attribute
    pageTitleService.setTitle('MightySignal - Ad Intelligence');

    // Sets user permissions
    authService.permissions()
      .success(function(data) {
        $scope.canViewAdSpend = data.can_view_ad_spend;
        $scope.canViewAdAttribution = data.can_view_ad_attribution;
        $scope.canViewExports = data.can_view_exports;
      });

    adIntelligenceCtrl.load = function(page, category, order) {
      $scope.currentPage = page || 1
      $scope.category = category || 'first_seen_ads'
      $scope.order = order || 'desc'

      $scope.isLoading = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/ad_intelligence/' + $scope.appPlatform.platform + '.json',
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
    };

    $scope.onAdIntelligenceAppClick = function(app) {
      var slacktivityData = {
        "title": "Ad Intelligence App Clicked",
        "fallback": "Ad Intelligence Viewed",
        "color": "#FFD94D", // yellow
        "appName": app.name,
        "appId": app.id,
        "appPlatform": app.type
      };
      slacktivity.notifySlack(slacktivityData);
      mixpanel.track(
        "App on Ad Intelligence Clicked", {
          "publisherName": app.publisher.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
    }

    $scope.toggledPlatform = function() {
      $scope.apps = [];
      $scope.numApps = 0;
      adIntelligenceCtrl.load();
    }

    adIntelligenceCtrl.updateCSVUrl = function() {
      var tokenParam =  $location.url().split('/ad-intelligence')[1] ? '&access_token=' : '?access_token='
      adIntelligenceCtrl.csvUrl = API_URI_BASE + 'api/ad_intelligence/' + $scope.appPlatform.platform + '.csv' + $location.url().split('/ad-intelligence')[1] + tokenParam + authToken.get()
    };

    // Computes class for last updated data in Last Updated column rows
    adIntelligenceCtrl.getDaysAgoClass = function(days) {
      return searchService.getLastUpdatedDaysClass(days);
    };

    adIntelligenceCtrl.calculateDaysAgo = function(date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0]; // returns '5 days' for example
    };

    adIntelligenceCtrl.submitPageChange = function(currentPage) {
      adIntelligenceCtrl.load(currentPage, $scope.category, $scope.order);
    };

    // When orderby/sort arrows on dashboard table are clicked
    adIntelligenceCtrl.sortApps = function(category, order) {
      var sign = order == 'desc' ? '-' : ''
      $scope.rowSort = sign + category

      mixpanel.track(
        "Table Sorting Changed", {
          "category": category,
          "order": order,
          "appPlatform": 'ios'
        }
      );
      adIntelligenceCtrl.load(1, category, order);
    };

    mixpanel.track("Ad Intelligence Viewed");
    var slacktivityData = {
      "title": "Ad Intelligence Viewed",
      "fallback": "Ad Intelligence Viewed",
      "color": "#FFD94D", // yellow
    };
    slacktivity.notifySlack(slacktivityData);

    adIntelligenceCtrl.load();
  }
]);
