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

      mixpanel.track("Ad Intelligence Viewed", {
        "platform": APP_PLATFORM
      });

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
        $rootScope.numPerPage = data.pageSize;
      });
    };

    $scope.adIntelItemClicked = function(item, type) {
      if (type == 'app') {
        var slacktivityData = {
          "title": "Ad Intelligence App Clicked",
          "fallback": "Ad Intelligence Viewed",
          "color": "#FFD94D", // yellow
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        };
        slacktivity.notifySlack(slacktivityData);
      }
      mixpanel.track(
        "Ad Intelligence Item Clicked", {
          "name": item.name,
          "id": item.id,
          "platform": APP_PLATFORM,
          type
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

    adIntelligenceCtrl.adExportButtonClicked = function () {
      mixpanel.track("Ad Intelligence Exported", {
        platform: APP_PLATFORM
      })
    }

    // Computes class for last updated data in Last Updated column rows
    adIntelligenceCtrl.getDaysAgoClass = function(days) {
      return searchService.getLastUpdatedDaysClass(days);
    };

    adIntelligenceCtrl.calculateDaysAgo = function(date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0]; // returns '5 days' for example
    };

    adIntelligenceCtrl.submitPageChange = function(currentPage) {
      adIntelligenceCtrl.load(currentPage, $scope.category, $scope.order);
      mixpanel.track("Ad Intelligence Paged Through", {
        "page": currentPage,
        "platform": APP_PLATFORM
      })
    };

    // When orderby/sort arrows on dashboard table are clicked
    adIntelligenceCtrl.sortApps = function(category, order) {
      var sign = order == 'desc' ? '-' : ''
      $scope.rowSort = sign + category

      mixpanel.track(
        "Ad Intelligence Table Sorting Changed", {
          "category": category,
          "order": order,
          "appPlatform": APP_PLATFORM
        }
      );
      adIntelligenceCtrl.load(1, category, order);
    };

    var slacktivityData = {
      "title": "Ad Intelligence Viewed",
      "fallback": "Ad Intelligence Viewed",
      "color": "#FFD94D", // yellow
    };
    slacktivity.notifySlack(slacktivityData);

    adIntelligenceCtrl.load();
  }
]);
