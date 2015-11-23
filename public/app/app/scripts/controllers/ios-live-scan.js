'use strict';

angular.module('appApp').controller("IosLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "appDataService", "sdkLiveScanService", "$interval",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, appDataService, sdkLiveScanService, $interval) {

    var iosLiveScanCtrl = this;

    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    $scope.$on('EVENT_ON_APP_DETAILS_LOAD_COMPLETION', function () {

      iosLiveScanCtrl.appData = appDataService.appData; // Service to share data between both controllers
      iosLiveScanCtrl.displayStatus = appDataService.appData.displayStatus;

      sdkLiveScanService.checkForIosSdks()
        .success(function (data) {
          iosLiveScanCtrl.sdkData = data;
        });

    });

    iosLiveScanCtrl.getSdks = function(appId) {
      sdkLiveScanService.startIosSdkScan(appId)
        .success(function(data) {
          pullScanStatus();
        })
        .error(function(err) {

        });
    };

    var pullScanStatus = function() {
      var msDelay = 3000;
      var numRepeat = 60;

      $interval(function() {
        sdkLiveScanService.getIosScanStatus()
          .success(function(data) {

          });
      }, msDelay, numRepeat);
    };

  }

]);
