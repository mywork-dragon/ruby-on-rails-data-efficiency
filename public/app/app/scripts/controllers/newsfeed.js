'use strict';

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService',
  function($scope, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService) {

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

    mixpanel.track("Timeline Viewed");

  }
]);
