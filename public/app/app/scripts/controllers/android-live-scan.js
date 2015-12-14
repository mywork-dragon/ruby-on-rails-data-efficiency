'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "sdkLiveScanService", "$interval",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, sdkLiveScanService, $interval) {

    var androidLiveScanCtrl = this;
    var androidAppId = $routeParams.id;
    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    // Takes an array and number of slices as params, splits into two
    var splitArray = function(a, n) {
      var len = a.length,out = [], i = 0;
      while (i < len) {
        var size = Math.ceil((len - i) / n--);
        out.push(a.slice(i, i + size));
        i += size;
      }
      return out;
    };

    androidLiveScanCtrl.checkForAndroidSdks = function(appId, calledAfterSuccess) {

      sdkLiveScanService.checkForAndroidSdks(appId)
        .success(function (data) {
          var installedSdks = splitArray(data.installed_sdks, 2);
          androidLiveScanCtrl.sdkData = {
            'sdkCompanies': installedSdks[0],
            'sdkOpenSource': installedSdks[1],
            'installedSdks': data.installed_sdks,
            'lastUpdated': data.updated,
            'errorCode': data.error_code
          };

          androidLiveScanCtrl.noSdkData = false;
          androidLiveScanCtrl.sdkLiveScanPageLoading = false;

          if(data == null) {
            androidLiveScanCtrl.noSdkData = true;
            androidLiveScanCtrl.sdkData = {'errorCodeMessage': "Error - Please Try Again Later"};
          }

          androidLiveScanCtrl.noSdkSnapshot = !data.installed_sdks.length;

          var errorCodeMessages = [
            "Sorry, SDKs Not Available for Paid Apps",
            "Sorry, SDKs Not Available - App is Not in U.S. App Store",
            "Sorry, SDKs Temporarily Not Available for This App"
          ];

          if (data.error_code != null) {
            androidLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
            androidLiveScanCtrl.hideLiveScanButton = true;
            sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($routeParams.platform, androidAppId, data.error_code, errorCodeMessages[data.error_code]); // Failed analytics response - MixPanel & Slacktivity
          }

          // LS Success Analytics - MixPanel & Slacktivity
          if(calledAfterSuccess) {
            sdkLiveScanService.iosLiveScanSuccessRequestAnalytics($routeParams.platform, appId, androidLiveScanCtrl.sdkData);
          }

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
          androidLiveScanCtrl.scanStatusMessage = "Validating...";
          androidLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating
          pullScanStatus();
        })
        .error(function() {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.failedLiveScan = true;
        });
    };

    // Helper method for getSdks() method
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
        "Sorry, SDKs Temporarily Not Available for This App"            // 4 == carrier problem
      ];

      var interval = $interval(function() {
        sdkLiveScanService.getAndroidScanStatus(androidLiveScanCtrl.scanJobId)
          .success(function(data) {
            intervalCount++;

            // Reset 'query in progress' if pulling times out
            if(intervalCount == 120) {
              androidLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.iosLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, -1); // Failed analytics response - MixPanel & Slacktivity
            }

            if(!data.status && data.status !== 0) { data.status = 4 } // If status is null, treat as failed (status 4)

            androidLiveScanCtrl.scanStatusMessage = statusCheckStatusCodeMessages[data.status]; // Sets scan status message

            switch(data.status) {
              case 0: // prepairing
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
                sdkLiveScanService.iosLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, 4); // Failed analytics response - MixPanel & Slacktivity
                break;
            }

            if(data.error || data.error === 0 || !data.status) { // if data.error is present, or both data.error and data.status not present
              androidLiveScanCtrl.sdkQueryInProgress = false;
              androidLiveScanCtrl.noSdkData = false;
              androidLiveScanCtrl.errorCodeMessage = statusCheckErrorCodeMessages[data.error || 0];
              androidLiveScanCtrl.hideLiveScanButton = true;
              androidLiveScanCtrl.sdkData = { 'errorCode': data.error };
              androidLiveScanCtrl.noSdkSnapshot = !data.installed && !data.uninstalled; // Will show/hide view elements depending on data returned

              sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($routeParams.platform, androidAppId, data.error, statusCheckErrorCodeMessages[data.error]); // Failed analytics response - MixPanel & Slacktivity
              $interval.cancel(interval); // Exits interval loop
            } else if(data.status == 3 || data.status == 4) { // if status 'success' or 'failed'
              // Run for any qualifying status
              androidLiveScanCtrl.sdkQueryInProgress = false;
              androidLiveScanCtrl.noSdkSnapshot = !data.installed && !data.uninstalled; // Will show/hide view elements depending on data returned

              $interval.cancel(interval); // Exits interval loop
            }

          })
          .error(function() {
            androidLiveScanCtrl.failedLiveScan = true;
          });

      }, msDelay, numRepeat);

    };

  }

]);
