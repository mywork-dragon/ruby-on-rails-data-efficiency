'use strict';

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "authService", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService', 'slacktivity', 'Lightbox',
  function($scope, authService, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService, slacktivity, Lightbox) {

    var newsfeedCtrl = this;
    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = true;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.page = 1;
    $scope.locations = [];
    newsfeedCtrl.weeks = [];


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

        $scope.following = data.following
        $scope.initialPageLoadComplete = true;
      });
    };

    $scope.loadBatch = function(id, batch, page, perPage) {
      page = page || 1

      mixpanel.track("Expanded Timeline Item", {
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type,
        batchId: id
      });

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
      var exportFileName = ownerName.toLowerCase() + '_' + batch.activity_type + '.csv'
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
      if ($scope.initialPageLoadComplete) {
        $scope.initialPageLoadComplete = false;
        $scope.page++;
        newsfeedCtrl.load();
      }
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
      var other_owner = activity.other_owner
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
