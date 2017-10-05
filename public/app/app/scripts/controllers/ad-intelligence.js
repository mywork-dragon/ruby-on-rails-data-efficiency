'use strict';

angular.module('appApp').controller("AdIntelligenceCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'slacktivity', 'searchService', 'sdkLiveScanService', 'authToken', '$location', '$rootScope', 'AppPlatform',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, slacktivity, searchService, sdkLiveScanService, authToken, $location, $rootScope, AppPlatform) {

    var adIntelligenceCtrl = this;
    $scope.platform = 'all';

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
      const sign = $scope.order == 'desc' ? '-' : ''
      $scope.rowSort = sign + $scope.category
      $scope.isLoading = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/ad_intelligence/' + $scope.platform + '.json',
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

    $scope.getNewAdvertiserCounts = function () {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/new_advertiser_counts'
      }).success(function(data) {
        $scope.newAdvertiserCounts = data
      })
    }

    $scope.getNewAdvertisersCsv = function (platform) {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/export_new_advertisers',
        params: { platform }
      }).success(function(data) {
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:attachment/csv,' + encodeURI(data);
        hiddenElement.target = '_blank';
        hiddenElement.download = `${platform}_new_advertisers.csv`;
        hiddenElement.click();
      })
    }

    $scope.adIntelItemClicked = function(item, type, platform) {
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
          platform,
          type
        }
      );
    }

    $scope.togglePlatform = function(platform) {
      $scope.apps = [];
      $scope.numApps = 0;
      $scope.platform = platform
      mixpanel.track("Ad Intelligence Viewed", {
        "platform": $scope.platform
      });
      adIntelligenceCtrl.load();
    }

    adIntelligenceCtrl.updateCSVUrl = function() {
      var tokenParam =  $location.url().split('/ad-intelligence')[1] ? '&access_token=' : '?access_token='
      adIntelligenceCtrl.csvUrl = API_URI_BASE + 'api/ad_intelligence/' + $scope.platform + '.csv' + $location.url().split('/ad-intelligence')[1] + tokenParam + authToken.get()
    };

    adIntelligenceCtrl.adExportButtonClicked = function () {
      mixpanel.track("Ad Intelligence Exported", {
        platform: $scope.platform
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
        "platform": $scope.platform
      })
    };

    // When orderby/sort arrows on dashboard table are clicked
    adIntelligenceCtrl.sortApps = function(category, order) {
      mixpanel.track(
        "Ad Intelligence Table Sorting Changed", {
          "category": category,
          "order": order,
          "appPlatform": $scope.platform
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

    mixpanel.track("Ad Intelligence Viewed", {
      "platform": $scope.platform
    });

    $scope.getNewAdvertiserCounts()
    adIntelligenceCtrl.load();

    $scope.shrinkTotalContainer = function () {
      $("#advertiser-total").width("120px")
      $("#advertiser-total").height("115px")
      $("#advertiser-total > .advertiser-csv-btn").css("visibility", "hidden")
    }

    $scope.expandTotalContainer = function () {
      $("#advertiser-total").width("143px")
      $("#advertiser-total").height("160px")
      $("#advertiser-total > .advertiser-csv-btn").css("visibility", "visible")
    }
  }
]);
