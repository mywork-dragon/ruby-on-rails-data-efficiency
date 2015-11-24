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

    iosLiveScanCtrl.checkSdkSnapshotStatus = function(data) {
      if(iosLiveScanCtrl.isEmpty(data.installed_sdk_companies) && iosLiveScanCtrl.isEmpty(data.installed_open_source_sdks)) {
        iosLiveScanCtrl.noSdkSnapshot = true;
      }
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

        iosLiveScanCtrl.checkSdkSnapshotStatus(data);

        var errorCodeMessages = [
          "Sorry, SDKs Not Available for Paid Apps",
          "Sorry, SDKs Not Available - Not in U.S. App Store",
          "Sorry, SDKs Temporarily Not Available for This App"
        ];

        if (data.error_code != null) {
          iosLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
        }

      });

    iosLiveScanCtrl.getSdks = function(appId) {
      iosLiveScanCtrl.sdkQueryInProgress = true;
      sdkLiveScanService.startIosSdkScan(appId)
        .success(function(data) {
          iosLiveScanCtrl.scanJobId = data.job_id;
          iosLiveScanCtrl.scanStatusMessage = "Validating...";
          pullScanStatus();
        })
        .error(function() {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
        });
    };

    // Helper method for getSdks() method
    var pullScanStatus = function() {
      var msDelay = 3000;
      var numRepeat = 60;

      // Messages that correspond to (status == index number)
      var statusCodeMessages = [
        "Validating...",           // Non-terminating
        "Unchanged",                // Unchanged
        "Not Available",            // Not Avaliable
        "Paid App",                 // Paid App
        "Device Incompatible",      // Device incompatible
        "Preparing...",            // Non-terminating
        "Downloading...",          // Non-terminating
        "Retrying...",             // Non-terminating
        "Scanning...",             // Non-terminating
        "Complete",               // Complete
        "Failed"                  // Failed
      ];

      $interval(function() {
        sdkLiveScanService.getIosScanStatus(iosLiveScanCtrl.scanJobId)
          .success(function(data) {

            iosLiveScanCtrl.scanStatusMessage = statusCodeMessages[data.status]; // Sets scan status message

            // If status is a terminating status (e.g. 'Not Available')
            if(data.status == 1) {
              iosLiveScanCtrl.displayDataUnchangedStatus = true;



              // Add corresponding code in view



            } else if(data.status >= 2 && data.status <= 4) {
              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
              iosLiveScanCtrl.noSdkData = false;
              iosLiveScanCtrl.errorCodeMessage = statusCodeMessages[data.status];
              iosLiveScanCtrl.sdkData.errorCode = -1;
              iosLiveScanCtrl.checkSdkSnapshotStatus(data); // Will show/hide view elements depending on data returned

              $interval.cancel(); // Exits interval loop

            } else if(data.status == 9 || data.status == 10) {
              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
              iosLiveScanCtrl.noSdkData = false;
              iosLiveScanCtrl.checkSdkSnapshotStatus(data); // Will show/hide view elements depending on data returned

              $interval.cancel(); // Exits interval loop

            }
          });
      }, msDelay, numRepeat);
    };

  }

]);
