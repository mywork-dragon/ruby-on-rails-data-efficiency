'use strict';

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService', 'slacktivity', 'Lightbox',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService, slacktivity, Lightbox) {

    var newsfeedCtrl = this;
    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = true;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.page = 1;
    newsfeedCtrl.weeks = []

    // Sets user permissions
    authService.permissions()
      .success(function(data) {
        $scope.canViewAdSpend = data.can_view_ad_spend;
        $scope.canViewAdAttribution = data.can_view_ad_attribution;
        $scope.canViewExports = data.can_view_exports;
      });

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
        type: batch.owner.type,
        batchId: id
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
      batch.isLoading = true
      $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed/details',
        params: {batchId: id, pageNum: page, perPage: perPage}
      }).success(function(data) {
        batch.activities = data.activities;
        batch.isLoading = false
        batch.currentPage = data.page
      });
    }

    $scope.exportBatch = function(id, batch) {

      if (!$scope.canViewExports) {
        angular.element('#exportPermissions').modal('show');
        return
      }
      var ownerName = batch.owner.name || 'facebook_ads'
      var exportFileName = ownerName.toLowerCase() + '_' + batch.activity_type + '.csv'
      mixpanel.track("Exported Timeline Item", {
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type,
        batchId: id
      });

      var slacktivityData = {
        "title": "Exported Timeline Item",
        "color": "#FFD94D",
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type
      };
      slacktivity.notifySlack(slacktivityData);

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed/export',
        params: {batchId: id}
      }).success(function(content) {
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
        hiddenElement.target = '_blank';
        hiddenElement.download = exportFileName;
        hiddenElement.click();
      })
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

    $scope.clickedTimelineItem = function(batch, activity, clickedType) {
      var other_owner = activity.other_owner.type == 'AdPlatform' ? activity.other_owner : activity.other_owner.app
      var type = other_owner.type
      var id = other_owner.id
      var activity_type = batch.activity_type
      var name = other_owner.name
      var platform = other_owner.platform
      clickedType = typeof clickedType !== 'undefined' ? clickedType : other_owner.type;
    //function(type, id, activity_type, name, platform, url) {
      mixpanel.track("Clicked Timeline Item", {
        activityType: activity_type,
        batchId: batch.id,
        itemName: name,
        itemId: id,
        itemType: type,
        clickedType: clickedType,
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

    $scope.openAdModal = function (batch, index) {
      var images = []
      for (var i in batch.activities) {
        images.push({url: batch.activities[i].other_owner.ad_image})
      }
      Lightbox.openModal(images, index);
    };

    $scope.openAdInfoModal = function (batch, index) {
      var images = []
      for (var i in batch.activities) {
        images.push({url: batch.activities[i].other_owner.ad_info_image})
      }
      Lightbox.openModal(images, index);
    };

    mixpanel.track("Timeline Viewed");

  }
]);
