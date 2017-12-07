import angular from 'angular';
import mixpanel from 'mixpanel-browser';
import _ from 'lodash';

import 'shared/export-permissions/export-permissions.directive';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService', 'slacktivity', 'Lightbox', 'csvUtils',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService, slacktivity, Lightbox, csvUtils) {

    var newsfeedCtrl = this;
    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = true;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.page = 1;
    $scope.locations = [];
    newsfeedCtrl.weeks = [];

    // Disable infinite scroll when feed returns no data.
    $scope.end_of_feed = false

    // Sets html title attribute
    pageTitleService.setTitle('MightySignal - Timeline');

    newsfeedCtrl.countryCodes = function() {
      return $scope.locations.map(function(location) {
        return location.id;
      })
    }

    // Sets user permissions
    authService.permissions()
      .success(function(data) {
        $scope.canViewAdSpend = data.can_view_ad_spend;
        $scope.canViewAdAttribution = data.can_view_ad_attribution;
        $scope.canViewExports = data.can_view_exports;
        $scope.locations = data.territories;

        newsfeedCtrl.load();
      });

    newsfeedCtrl.load = function(shouldReset) {
      if (shouldReset) {
        newsfeedCtrl.weeks = [];
        $scope.initialPageLoadComplete = false;
        $scope.page = 1;
        $scope.end_of_feed = false;
      }
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed',
        params: {page: $scope.page, 'country_codes[]': newsfeedCtrl.countryCodes()}
      }).success(function(data) {
        if (shouldReset) {
          newsfeedCtrl.weeks = _.sortBy(data.weeks, 'week').reverse();
        } else {
          newsfeedCtrl.weeks = _.sortBy(newsfeedCtrl.weeks.concat(data.weeks), 'week').reverse();
        }
        if (data.weeks.length == 0 && data.following.length == 0) {
          $scope.end_of_feed = true;
        }
        $scope.following = data.following
        $scope.initialPageLoadComplete = true;
      });
    };

    $scope.isSdk = function (type) {
      return type == "IosSdk" || type == "AndroidSdk"
    }

    $scope.isApp = function (type) {
      return type == "IosApp" || type == "AndroidApp"
    }

    $scope.loadBatch = function(id, batch, page, perPage, collapsed) {
      page = page || 1
      if (!collapsed && page == 1) {
        mixpanel.track("Expanded Timeline Item", {
          activityType: batch.activity_type,
          owner: batch.owner.name,
          platform: batch.owner.platform,
          type: batch.owner.type,
          batchId: id,
          "Activities Count": batch.activities_count
        });
      } else if (!collapsed && page > 1) {
        mixpanel.track("Expanded Timeline Item Paged Through", {
          activityType: batch.activity_type,
          owner: batch.owner.name,
          platform: batch.owner.platform,
          type: batch.owner.type,
          batchId: id,
          page: page
        });
      }

      batch.isLoading = true
      $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed/details',
        params: {batchId: id, pageNum: page, perPage: perPage, 'country_codes[]': newsfeedCtrl.countryCodes()}
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
      var exportFileName = ownerName.toLowerCase() + '_' + batch.activity_type
      mixpanel.track("Exported Timeline Item", {
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type,
        batchId: id
      });

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed/export',
        params: {batchId: id, 'country_codes[]': newsfeedCtrl.countryCodes()}
      }).success(function(content) {
        csvUtils.downloadCsv(content, exportFileName)
      })
    }

    $scope.newFollow = function(followable, action) {
      const follow = {
        id: followable.id,
        type: followable.type,
        name: followable.name,
        source: 'followModal',
        action
      }
      newsfeedService.follow(follow).success(function(data) {
        followable.following = data.is_following;
        $scope.following = data.following;
      });
    }

    $scope.loadMoreBatches = function() {
      if ($scope.initialPageLoadComplete) {
        $scope.initialPageLoadComplete = false;
        $scope.page++;
        newsfeedCtrl.load();
      }
    }

    $scope.infiniteScrollDisabled = function() {
      return $scope.end_of_feed;
    }

    $scope.locationAutocompleteUrl = function(status) {
      return API_URI_BASE + "api/location/autocomplete?status=" + status + "&query="
    }

    $scope.removeLocation = function(index) {
      var countryCode = $scope.locations[index].id
      $scope.locations.splice(index, 1)

      $http({
        method: 'POST',
        url: API_URI_BASE + 'api/newsfeed/remove_country',
        params: {country_code: countryCode}
      }).success(function(content) {
        mixpanel.track("Removed Country from Timeline", {
          countryCode: countryCode,
        });
        $scope.loadWithDelay()
      })
    }

    $scope.loadWithDelay = function() {
      // to prevent timeline from reloading too frequently
      if ($scope.timer) {
        clearTimeout($scope.timer)
      }
      $scope.timer = setTimeout(function() {
        newsfeedCtrl.load(true);
      }, 1500)
    }

    $scope.selectedCountry = function ($item) {
      var index = $scope.locations.indexOf($item.originalObject)
      var countryCode = $item.originalObject.id
      if (index < 0) {
        $scope.locations.push($item.originalObject)
      }
      $http({
        method: 'POST',
        url: API_URI_BASE + 'api/newsfeed/add_country',
        params: {country_code: countryCode}
      }).success(function(content) {
        mixpanel.track("Added Country to Timeline", {
          countryCode: countryCode,
        });
        $scope.loadWithDelay()
      })
    }

    $scope.clickedTimelineItem = function(batch, activity, clickedType) {
      const otherOwner = activity.other_owner
      clickedType = typeof clickedType !== 'undefined' ? clickedType : otherOwner.type;
      mixpanel.track("Clicked Timeline Item", {
        owner: batch.owner.name,
        activityType: batch.activity_type,
        batchId: batch.id,
        itemName: otherOwner.name,
        itemId: otherOwner.id,
        itemType: otherOwner.type,
        clickedType: clickedType,
      });
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

    $scope.majorAppIconClicked = function (activity, owner, activity_type) {
      const slacktivityData = {
        "title": "Major App Icon Clicked",
        "fallback": "Major App Icon Clicked",
        "color": "#FFD94D",
        "app id": activity.app.id,
        "owner id": owner.id,
        "owner type": owner.type,
        "activity": activity_type
      }
      slacktivity.notifySlack(slacktivityData);
      mixpanel.track("Major App Icon Clicked", {
        activityType: activity_type,
        owner: owner.name,
        platform: owner.platform,
        ownerType: owner.type,
        app: activity.app.name,
        appId: activity.app.id
      });
    }

    $scope.majorAppIconHovered = function () {
      $scope.hoverStartTime = new Date();
    }

    $scope.majorAppIconExited = function (activity, owner, activity_type) {
      $scope.hoverEndTime = new Date();
      const hoverTime = $scope.hoverEndTime.getTime() - $scope.hoverStartTime.getTime();
      if (hoverTime > 400) {
        mixpanel.track("Major App Icon Hovered", {
          activityType: activity_type,
          owner: owner.name,
          platform: owner.platform,
          ownerType: owner.type,
          app: activity.app.name,
          appId: activity.app.id
        });
      }
    }
  }
]);
