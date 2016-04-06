'use strict';

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService', 'slacktivity',
  function($scope, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService, slacktivity) {

    var newsfeedCtrl = this;
    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = true;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.page = 1;
    newsfeedCtrl.weeks = []

    newsfeedCtrl.load = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed',
        params: {page: $scope.page}
      }).success(function(data) {
        newsfeedCtrl.weeks = _.sortBy(newsfeedCtrl.weeks.concat(data.weeks), 'week').reverse();
        $scope.following = data.following
        $scope.initialPageLoadComplete = true;

        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Timeline');

      });

    };

    newsfeedCtrl.load();

    $scope.loadBatch = function(id, batch, page, perPage) {
      page = page || 1

      mixpanel.track("Expanded Timeline Item", {
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type
      });

      var slacktivityData = {
        "title": "Expanded Timeline Item",
        "color": "#FFD94D",
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type
      };
      slacktivity.notifySlack(slacktivityData);

      $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed_details',
        params: {batchId: id, pageNum: page, perPage: perPage}
      }).success(function(data) {
        batch.activities = data.activities;
        batch.currentPage = data.page
      });
    }

    $scope.newFollow = function(id, type, name, follow) {
      newsfeedService.follow(id, type, name).success(function(data) {
        follow.following = data.following
      });
    }

    $scope.loadMoreBatches = function() {
      $scope.page++;
      newsfeedCtrl.load();
    }

    $scope.clickedTimelineItem = function(type, id, activity_type, name, platform) {
      mixpanel.track("Clicked Timeline Item", {
        activityType: activity_type,
        clickedName: name,
        clickedId: id,
        clickedType: type
      });

      var platform = 'ios'
      var class_name = 'app'
      
      if (type == 'AndroidSdk' || type == 'AndroidApp') {
        platform = 'android'
      }
      if (type == 'AndroidSdk' || type == 'IosSdk') {
        class_name = 'sdk'
      }

      var slacktivityData = {
        "title": "Clicked Timeline Item",
        "color": "#FFD94D",
        'type': type,
        'name': name,
        'url': "http://mightysignal.com/app/app#/" + class_name + '/' + platform + '/' + id,
      };
      slacktivity.notifySlack(slacktivityData);
    }

    mixpanel.track("Timeline Viewed");

  }
]);
