'use strict';

angular.module('appApp').controller("IosLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "appDataService", "sdkLiveScanService", "$interval",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, appDataService, sdkLiveScanService, $interval) {

    var iosLiveScanCtrl = this;

    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    $scope.$on('EVENT_ON_APP_DETAILS_LOAD_COMPLETION', function () {
      iosLiveScanCtrl.appData = appDataService.appData; // Service to share data between both controllers
    });

    iosLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    sdkLiveScanService.checkForIosSdks()
      .success(function (data) {
        iosLiveScanCtrl.sdkData = {
          'sdkCompanies': data.installed_sdk_companies,
          'sdkOpenSource': data.installed_open_source_sdks,
          'lastUpdated': data.updated,
          'errorCode': data.error_code
        };

        iosLiveScanCtrl.noSdkData = false;

        if(data == null) {
          iosLiveScanCtrl.noSdkData = true;
          iosLiveScanCtrl.sdkData = {'errorCodeMessage': "Error - Please Try Again Later"}
        }

        if(iosLiveScanCtrl.isEmpty(data.installed_sdk_companies) && iosLiveScanCtrl.isEmpty(data.installed_open_source_sdks)) {
          iosLiveScanCtrl.noSdkSnapshot = true;
        }

        var errorCodeMessages = [
          "Price",
          "Taken Down or Foreign",
          "Device Incompatible"
        ];
        if (data.error_code != null) {
          iosLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
        }

      });

    iosLiveScanCtrl.getSdks = function(appId) {
      iosLiveScanCtrl.sdkQueryInProgress = true;
      sdkLiveScanService.startIosSdkScan(appId)
        .success(function(data) {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
          iosLiveScanCtrl.noSdkData = false;
          pullScanStatus();
        })
        .error(function(err) {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
        });
    };

    var pullScanStatus = function() {
      var msDelay = 3000;
      var numRepeat = 60;

      // Messages that correspond to (status == index number)
      var statusCodeMessages = [
        "Validating",           // Non-terminating
        "Unchanged",
        "Not Available",
        "Paid App",
        "Device Incompatible",
        "Preparing",            // Non-terminating
        "Downloading",          // Non-terminating
        "Retrying",             // Non-terminating
        "Scanning",             // Non-terminating
        "Complete",
        "Failed"
      ];

      $interval(function() {
        sdkLiveScanService.getIosScanStatus()
          .success(function(data) {
            // If status is a terminating status (e.g. 'Not Available')
            if((data.status >= 1 && data.status <= 4) || data.status == 9 || data.status == 10) {
              $interval.cancel(); // Exits interval loop
            }
          });
      }, msDelay, numRepeat);
    };

  }

]);
