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
            'errorCode': data.error_code
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
            "Sorry, SDKs Not Available - App is Not in U.S. App Store",   // country problem
            "Sorry, SDKs Temporarily Not Available for This App",         // device problem
            "Sorry, SDKs Temporarily Not Available for This App",         // carrier problem
            "Sorry, SDKs Temporarily Not Available for This App",         // couldn't find
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
        "Failed"
      ];

      var statusCheckErrorCodeMessages = [
        "Sorry, SDKs Temporarily Not Available for This App",           // 0 == error connecting with Google
        "Sorry, SDKs Not Available - App is Not in U.S. App Store",     // 1 == taken down
        "Sorry, SDKs Temporarily Not Available for This App",           // 2 == device problems
        "Sorry, SDKs Not Available - App is Not in U.S. App Store",     // 3 == country problem
        "Sorry, SDKs Temporarily Not Available for This App",            // 4 == carrier problem
        "App data has not changed since last scan. Currently up-to-date." // 5 == unchanged version (message not actually used)
      ];

      var interval = $interval(function() {
        sdkLiveScanService.getAndroidScanStatus(androidLiveScanCtrl.scanJobId)
          .success(function(data) {
            intervalCount++;

            var statusCode = data.status;
            var errorCode = data.error;

            // Reset 'query in progress' if polling times out
            if(intervalCount == numRepeat) {
              androidLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, -1, "Timeout"); // Failed analytics response - MixPanel & Slacktivity
            }

            if(!statusCode && statusCode!== 0) { statusCode = 4 } // If status is null, treat as failed (status 4)

            var statusMessage = statusCheckStatusCodeMessages[statusCode];
            var errorMessage = statusCheckErrorCodeMessages[errorCode];

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
                break;
              case 4: // failed
                androidLiveScanCtrl.noSdkData = true;
                androidLiveScanCtrl.failedLiveScan = true;
                if(data.error != 5) { // don't count no now version as fail
                  sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, statusCode, statusMessage, errorCode, errorMessage); // Failed analytics response - MixPanel & Slacktivity
                }
                break;
            }

            if(data.error || data.error === 0 || !data.status && data.status !== 0) { // if data.error is present, or both data.error and data.status not present

              $interval.cancel(interval); // Exits interval loop

              androidLiveScanCtrl.sdkQueryInProgress = false;
              androidLiveScanCtrl.noSdkData = false;
              androidLiveScanCtrl.errorCodeMessage = statusCheckErrorCodeMessages[data.error || 0];
              // androidLiveScanCtrl.hideLiveScanButton = true;

              if(data.error == 5) {
                androidLiveScanCtrl.checkForAndroidSdks(androidAppId);
                androidLiveScanCtrl.versionUnchanged = true;
                androidLiveScanCtrl.hideLiveScanButton = false;
                sdkLiveScanService.androidLiveScanUnchangedVersionSuccess($routeParams.platform, androidAppId);
              }
              else {
                androidLiveScanCtrl.sdkData = { 'errorCode': data.error };
                androidLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.androidLiveScanHiddenSdksAnalytics($routeParams.platform, androidAppId, data.error, statusCheckErrorCodeMessages[data.error]);
              }

            } else if(data.status == 3 || data.status == 4) { // if status 'success' or 'failed'

              $interval.cancel(interval); // Exits interval loop

              // Run for any qualifying status
              androidLiveScanCtrl.sdkQueryInProgress = false;
            }

          })
          .error(function() {
            androidLiveScanCtrl.failedLiveScan = true;
          });

      }, msDelay, numRepeat);

    };

  }

]);
