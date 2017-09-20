'use strict';

angular.module('appApp').controller("ChartsCtrl", ["$scope", 'authToken', 'slacktivity', '$route', "authService", "$http", "pageTitleService", "listApiService", "apiService",
  function($scope, authToken, slacktivity, $route, authService, $http, pageTitleService, listApiService, apiService) {

    var chartsCtrl = this;
    $scope.order = 'desc';
    $scope.category = 'monthly_active_users_num'
    $scope.rowSort = '-monthly_active_users_num'

    pageTitleService.setTitle("MightySignal - Charts")

    // Sets user permissions
    authService.permissions()
      .success(function(data) {
        $scope.canViewExports = data.can_view_exports;
      });

    chartsCtrl.loadTopApps = function(platform) {
      var path = platform == 'ios' ? 'api/charts/top-ios-apps' : 'api/charts/top-android-apps'
      return $http({
        method: 'GET',
        url: API_URI_BASE + path
      }).success(function(data) {
        $scope.apps = data.apps
        $scope.initialPageLoadComplete = true;
      });
    };

    chartsCtrl.loadSdks = function(platform) {
      var path = platform == 'ios' ? 'api/charts/ios-sdks' : 'api/charts/android-sdks'
      return $http({
        method: 'GET',
        url: API_URI_BASE + path
      }).success(function(data) {
        $scope.sdks = data.sdks
        $scope.initialPageLoadComplete = true;
      });
    };

    chartsCtrl.loadIosEngagement = function(category, order) {
      $scope.category = category || 'monthly_active_users_num'
      $scope.order = order || 'desc'
      $scope.isLoading = true

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/charts/ios-engagement.json',
        params: {orderBy: $scope.order, sortBy: $scope.category}
      }).success(function(data) {
        $scope.apps = data.apps
        $scope.numApps = data.apps.length
        $scope.isLoading = false;
      });
    };

    chartsCtrl.CSVUrl = function() {
      return API_URI_BASE + 'api/charts/ios-engagement.csv?orderBy=asc&sortBy=monthly_active_users_rank&access_token=' + authToken.get()
    }

    $scope.sortApps = function(category, order) {
      var sign = order == 'desc' ? '-' : ''
      $scope.rowSort = sign + category

      mixpanel.track(
        "Table Sorting Changed", {
          "category": category,
          "order": order,
          "appPlatform": 'ios'
        }
      );
      chartsCtrl.loadIosEngagement(category, order);
    };

    $scope.clickedSdkTag = function(tag) {
      $scope.tag = tag
    }

    $scope.onIosEngagementAppClick = function(app) {
      var slacktivityData = {
        "title": "Ios Engagement App Clicked",
        "color": "#FFD94D", // yellow
        "appName": app.name,
        "appId": app.id,
        "appPlatform": app.type
      };
      slacktivity.notifySlack(slacktivityData);
      mixpanel.track(
        "App on Ios Engagement Clicked", {
          "publisherName": app.publisher.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
    }
    var title;

    switch ($route.current.action) {
      case "charts.top-ios-apps":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadTopApps('ios')
        pageTitleService.setTitle('MightySignal - iTunes Top 200 Apps');
        title = "Top iOS Apps Viewed"
        break;
      case "charts.top-android-apps":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadTopApps('android')
        pageTitleService.setTitle('MightySignal - Google Play Top 200 Apps');
        title = "Top Android Apps Viewed"
        break;
      case "charts.ios-sdks":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadSdks('ios')
        pageTitleService.setTitle('MightySignal - iOS SDKs');
        title = "iOS SDKs Viewed"
        break;
      case "charts.android-sdks":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadSdks('android')
        pageTitleService.setTitle('MightySignal - Android SDKs');
        title = "Android SDKs Viewed"
        break;
      case "charts.ios-engagement":
        $scope.initialPageLoadComplete = false;
        chartsCtrl.loadIosEngagement();
        pageTitleService.setTitle('MightySignal - iOS Apps by Active Users');
        title = "iOS Apps by Active Users Viewed"
        break;
    }

    var slacktivityData = {
      "title": title,
      "fallback": title,
      "color": "#FFD94D"
    };
    slacktivity.notifySlack(slacktivityData);

    mixpanel.track(title)

    $scope.topChartsItemClicked = function (app, type) {
      const item = type == 'app' ? app : app.publisher;
      mixpanel.track("Top Charts Item Clicked", {
        "Name": item.name,
        "Id": item.id,
        platform: app.platform,
        type
      })
    }

  }
]);
