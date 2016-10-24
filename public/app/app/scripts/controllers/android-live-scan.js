'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "sdkLiveScanService", "$interval", "$timeout",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, sdkLiveScanService, $interval, $timeout) {

    var androidLiveScanCtrl = this;
    var androidAppId = $routeParams.id;
    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    androidLiveScanCtrl.calculateDaysAgo = function(date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0]; // returns '5 days' for example
    };

    androidLiveScanCtrl.checkForAndroidSdks = function(appId, calledAfterSuccess) {

      sdkLiveScanService.checkForAndroidSdks(appId)
        .success(function (data) {
          androidLiveScanCtrl.sdkData = {
            'sdkCompanies': data.installed,
            'sdkOpenSource': data.uninstalled,
            'lastUpdated': data.updated,
            'errorCode': data.error_code,
            'liveScanEnabled': data.live_scan_enabled
          };

          androidLiveScanCtrl.noSdkData = false;
          androidLiveScanCtrl.sdkLiveScanPageLoading = false;

          if(data == null) {
            androidLiveScanCtrl.noSdkData = true;
            androidLiveScanCtrl.sdkData = {'errorCodeMessage': "Error - Please Try Again Later"};
          }

          androidLiveScanCtrl.noSdkSnapshot = (!data.installed || !data.installed.length) && (!data.installed || !data.uninstalled.length);

          var errorCodeMessages = [
            "Sorry, SDKs Not Available - App is Not in U.S. App Store",   // taken down
            "Sorry, SDKs Not Available - App is Not in U.S. App Store",   // foreign
            "Sorry, SDKs Not Available for Paid Apps"                     // paid app
          ];

          if (data.error_code != null) {
            androidLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
            sdkLiveScanService.androidLiveScanHiddenSdksAnalytics($routeParams.platform, androidAppId, data.error_code, errorCodeMessages[data.error_code]); // Failed analytics response - MixPanel & Slacktivity
          }

          // LS Success Analytics - MixPanel & Slacktivity
          if(calledAfterSuccess) {
            sdkLiveScanService.androidLiveScanSuccessRequestAnalytics($routeParams.platform, appId, androidLiveScanCtrl.sdkData);
          }

          /* Initializes all Bootstrap tooltips */
          $timeout(function() {
            $(function () { $('[data-toggle="tooltip"]').tooltip() });
          }, 1000);

        });

    };

    androidLiveScanCtrl.sdkLiveScanPageLoading = true; // on initial page load
    androidLiveScanCtrl.checkForAndroidSdks(androidAppId); // Call for initial SDKs load

    androidLiveScanCtrl.getSdks = function() {

      // Reset all view-changing vars
      androidLiveScanCtrl.sdkQueryInProgress = true;
      androidLiveScanCtrl.displayDataUnchangedStatus = false;
      androidLiveScanCtrl.failedLiveScan = false;
      androidLiveScanCtrl.errorCodeMessage = null;
      androidLiveScanCtrl.sdkData = null;
      androidLiveScanCtrl.hideLiveScanButton = false;
      androidLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating

      sdkLiveScanService.startAndroidSdkScan(androidAppId)
        .success(function(data) {
          androidLiveScanCtrl.scanJobId = data.job_id;
          androidLiveScanCtrl.scanStatusMessage = "Preparing...";
          androidLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating
          pullScanStatus();
        })
        .error(function() {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.failedLiveScan = true;
        });
    };

    // Helper method for getSdks() method - 4min timeout (2s * 120)
    var pullScanStatus = function() {
      var msDelay = 2000;
      var numRepeat = 120;
      var intervalCount = 0;

      // Messages that correspond to (status == index number)
      var statusCheckStatusCodeMessages = [
        "Preparing...",
        "Downloading...",
        "Scanning...",
        "Complete",
        "Sorry, Live Scan Failed. Please Try Again Later",
        "Sorry, SDKs Temporarily Not Available for This App", 
        "Sorry, SDKs Not Available for Paid Apps",
        "App data has not changed since last scan. Currently up-to-date."
      ];

      var interval = $interval(function() {
        sdkLiveScanService.getAndroidScanStatus(androidLiveScanCtrl.scanJobId)
          .success(function(data) {
            intervalCount++;

            var statusCode = data.status;

            // Reset 'query in progress' if polling times out
            if(intervalCount == numRepeat) {
              androidLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, -1, "Timeout"); // Failed analytics response - MixPanel & Slacktivity
            }

            if(!statusCode && statusCode !== 0) { statusCode = 4 } // If status is null, treat as failed (status 4)

            var statusMessage = statusCheckStatusCodeMessages[statusCode];

            androidLiveScanCtrl.scanStatusMessage = statusMessage; // Sets scan status message

            switch(data.status) {
              case 0: // preparing
                androidLiveScanCtrl.scanStatusPercentage = 5;
                break;
              case 1: // downloading
                androidLiveScanCtrl.scanStatusPercentage = 20;
                break;
              case 2: // scanning
                androidLiveScanCtrl.scanStatusPercentage = 70;
                break;
              case 3: // complete
                androidLiveScanCtrl.scanStatusPercentage = 100;
                androidLiveScanCtrl.noSdkData = false;
                androidLiveScanCtrl.checkForAndroidSdks(androidAppId, true); // Loads new sdks on page

                $interval.cancel(interval); // Exits interval loop

                // Run for any qualifying status
                androidLiveScanCtrl.sdkQueryInProgress = false;
                break;
              case 4: // failed
              case 5: // unavailable
              case 6: // paid
                androidLiveScanCtrl.noSdkData = true;

                $interval.cancel(interval); // Exits interval loop

                androidLiveScanCtrl.sdkQueryInProgress = false;
                androidLiveScanCtrl.errorCodeMessage = statusMessage;

                androidLiveScanCtrl.failedLiveScan = true;
                androidLiveScanCtrl.sdkData = { 'errorCode': data.status };
                androidLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, statusCode, statusMessage); // Failed analytics response - MixPanel & Slacktivity
                break;
              case 7: //unchanged
                androidLiveScanCtrl.noSdkData = false;
                $interval.cancel(interval); // Exits interval loop

                androidLiveScanCtrl.sdkQueryInProgress = false;
                androidLiveScanCtrl.errorCodeMessage = statusMessage;

                androidLiveScanCtrl.checkForAndroidSdks(androidAppId);
                androidLiveScanCtrl.versionUnchanged = true;
                androidLiveScanCtrl.hideLiveScanButton = false;
                sdkLiveScanService.androidLiveScanUnchangedVersionSuccess($routeParams.platform, androidAppId);
                break;
            }

          })
          .error(function() {
            androidLiveScanCtrl.failedLiveScan = true;
          });

      }, msDelay, numRepeat);

    };

  }

]);
