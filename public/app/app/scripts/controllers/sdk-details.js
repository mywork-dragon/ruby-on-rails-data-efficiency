'use strict';

angular.module('appApp').controller("SdkDetailsCtrl", ["$http", "$routeParams", "$window", "pageTitleService", "authService",
  function($http, $routeParams, $window, pageTitleService, authService) {

    var sdkDetailsCtrl = this; // same as sdkCtrl = sdkDetailsCtrl

    var sdkPlatform = $routeParams.platform;

    // User info set
    var userInfo = {};
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    authService.permissions()
      .success(function(data) {
        if(!data.can_view_storewide_sdks) {
          $window.location.href = "#/search";
        }
      });

    sdkDetailsCtrl.load = function() {

      sdkDetailsCtrl.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/sdk',
        params: {id: $routeParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        sdkDetailsCtrl.sdkData = data;
        sdkDetailsCtrl.queryInProgress = false;
        /* Sets html title attribute */

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "SDK Details Page Viewed", {
            "sdkName": sdkDetailsCtrl.name,
            "platform": sdkPlatform
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        /* -------- Slacktivity Alerts -------- */
        if(userInfo.email && userInfo.email.indexOf('mightysignal') < 0) {
          var slacktivityData = {
            "title": "SDK Details Page Viewed",
            "fallback": "SDK Details Page Viewed",
            "color": "#FFD94D", // yellow
            "userEmail": userInfo.email
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
        }
        /* -------- Slacktivity Alerts End -------- */
      }).error(function() {
        sdkDetailsCtrl.queryInProgress = false;
      });
    };
    sdkDetailsCtrl.load();

    sdkDetailsCtrl.submitSdkQuery = function() {
      var path = API_URI_BASE + "app/app#/search?app=%7B%22sdkNames%22:%5B%7B%22id%22:" + sdkDetailsCtrl.sdkData.id + ",%22name%22:%22" + encodeURI(sdkDetailsCtrl.sdkData.name) + "%22%7D%5D%7D&company=%7B%7D&custom=%7B%7D&pageNum=1&pageSize=100&platform=%7B%22appPlatform%22:%22android%22%7D";
      $window.location.href = path;
    };

  }
]);
