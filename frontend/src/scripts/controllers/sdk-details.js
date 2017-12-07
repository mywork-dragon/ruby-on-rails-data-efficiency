import angular from 'angular';
import mixpanel from 'mixpanel-browser';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp').controller("SdkDetailsCtrl", ['$scope', '$q', "$http", "$stateParams", "$window", 'loggitService', "pageTitleService", "authService", 'newsfeedService', 'slacktivity',
  function($scope, $q, $http, $stateParams, $window, loggitService, pageTitleService, authService, newsfeedService, slacktivity) {

    var sdkDetailsCtrl = this; // same as sdkCtrl = sdkDetailsCtrl

    $scope.appPlatform = $stateParams.platform;

    $scope.tags = []
    $scope.editMode = false

    authService.permissions()
      .success(function(data) {
        if(!data.can_view_storewide_sdks) {
          $window.location.href = "#/search";
        }
      });

    $scope.initialPageLoadComplete = false;
    sdkDetailsCtrl.load = function() {

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/sdk/' + $stateParams.platform,
        params: {id: $stateParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        sdkDetailsCtrl.sdkData = data;
        if (data.tags) {
          for (var i = 0; i < data.tags.length; i++) {
            $scope.tags.push({text: data.tags[i].name})
          }
        }
        $scope.isFollowing = data.following
        sdkDetailsCtrl.apps = data.apps;
        $scope.apps = data.apps
        sdkDetailsCtrl.numApps = data.apps.length;

        $scope.initialPageLoadComplete = true;

        mixpanel.track(
          "SDK Details Page Viewed", {
            "sdkName": sdkDetailsCtrl.sdkData.name,
            "platform": $scope.appPlatform
          }
        );
      }).error(function() {
        sdkDetailsCtrl.queryInProgress = false;
      });
    };
    sdkDetailsCtrl.load();

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
        case "followed":
          return loggitService.logSuccess("You will now see updates for this SDK on your Timeline");
        case "unfollowed":
          return loggitService.logSuccess("You will stop seeing updates for this SDK on your Timeline");
      }
    };

    sdkDetailsCtrl.addSelectedTo = function(list) {
      console.log('Uh oh...this is used'); // commenting out because not used but cannot compile
      // var selectedApp = [{
      //   id: $stateParams.id,
      //   type: $stateParams.platform == 'IosApp' ? 'ios' : 'android'
      // }];
      // listApiService.addSelectedTo(list, selectedApp, $scope.appPlatform).success(function() {
      //   $scope.notify('add-selected-success');
      //   $rootScope.selectedAppsForList = [];
      // }).error(function() {
      //   $scope.notify('add-selected-error');
      // });
      // $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.followSdk = function(id, action) {
      const follow = {
        id,
        type: $stateParams.platform == 'ios' ? 'IosSdk' : 'AndroidSdk',
        name: sdkDetailsCtrl.sdkData.name,
        action,
        source: 'sdkDetails'
      }
      newsfeedService.follow(follow).success(function(data) {
        $scope.isFollowing = data.is_following
        if (data.is_following) {
          $scope.notify('followed');
        } else {
          $scope.notify('unfollowed');
        }
      });
    }

    $scope.onAppTableAppClick = function(app) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "App on SDK Page Clicked", {
          "sdkName": sdkDetailsCtrl.sdkData.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
      /* -------- Mixpanel Analytics End -------- */
    };

    $scope.loadTags = function(query) {
      var deferred = $q.defer();
      $http.get(API_URI_BASE + 'api/tags?query=' + query).success(function(data) {
        for (var i = 0; i < data.length; i++) {
          data[i].text = data[i].name;
          delete data[i].name;
        }
        deferred.resolve(data)
      })
      return deferred.promise
    };

    $scope.saveTags = function() {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/sdk/' + $stateParams.platform + '/tags',
        params: {tags: JSON.stringify($scope.tags), id: $stateParams.id}
      }).success(function(data) {
        sdkDetailsCtrl.sdkData.tags = data.tags
        $scope.editMode = false
      })
    }

    $scope.toggleEdit = function() {
      $scope.editMode = true
    }

    // Submits filtered search query via query string params
    sdkDetailsCtrl.submitSdkQuery = function(platform) {
      var path = API_URI_BASE + "app/app#/search?app=%7B%22sdkFiltersAnd%22:%5B%7B%22id%22:" + sdkDetailsCtrl.sdkData.id + ",%22status%22:%220%22,%22date%22:%220%22,%22name%22:%22" + encodeURI(sdkDetailsCtrl.sdkData.name) + "%22%7D%5D%7D&company=%7B%7D&pageNum=1&pageSize=100&platform=%7B%22appPlatform%22:%22" + platform + "%22%7D";
      $window.location.href = path;
    };

  }
]);
