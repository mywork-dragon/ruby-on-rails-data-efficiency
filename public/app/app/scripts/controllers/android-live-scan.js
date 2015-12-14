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










            if(!data.status && data.status !== 0) { data.status = 11 } // If status is null, treat as failed (status 10)

            androidLiveScanCtrl.scanStatusMessage = statusCheckStatusCodeMessages[data.status]; // Sets scan status message

            switch(data.status) {
              case 0:
                androidLiveScanCtrl.scanStatusPercentage = 5;
                break;
              case 1:
                androidLiveScanCtrl.displayDataUnchangedStatus = true;
                androidLiveScanCtrl.checkForAndroidSdks(androidAppId, true); // Loads new sdks on page
                break;
              case 5:
                androidLiveScanCtrl.scanStatusPercentage = 10;
                break;
              case 7:
                androidLiveScanCtrl.scanStatusPercentage = 20;
                break;
              case 8:
                androidLiveScanCtrl.scanStatusPercentage = 50;
                break;
              case 9:
                androidLiveScanCtrl.scanStatusPercentage = 90;
                break;
              case 10:
                androidLiveScanCtrl.scanStatusPercentage = 100;
                androidLiveScanCtrl.noSdkData = false;
                androidLiveScanCtrl.checkForAndroidSdks(androidAppId, true, 10); // Loads new sdks on page
                break;
              case 11:
                androidLiveScanCtrl.noSdkData = true;
                androidLiveScanCtrl.failedLiveScan = true;
                sdkLiveScanService.iosLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, 11); // Failed analytics response - MixPanel & Slacktivity
                break;
            }

            // If status 2, 3 or 4
            if((data.status >= 2 && data.status <= 4) || data.status == 6) {

              // Run for any qualifying status
              androidLiveScanCtrl.sdkQueryInProgress = false;
              androidLiveScanCtrl.noSdkData = false;
              androidLiveScanCtrl.errorCodeMessage = statusCheckStatusCodeMessages[data.status];
              androidLiveScanCtrl.sdkData = { 'errorCode': -1 };

              androidLiveScanCtrl.noSdkSnapshot = !data.installed_sdks; // Will show/hide view elements depending on data returned

              if(data.status != 6) {
                androidLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($routeParams.platform, androidAppId, data.status, statusCheckStatusCodeMessages[data.status]); // Failed analytics response - MixPanel & Slacktivity
              }

              $interval.cancel(interval); // Exits interval loop

            } else if(data.status == 1 || data.status == 10 || data.status == 11) { // if status 1, 9 or 10
              // Run for any qualifying status
              androidLiveScanCtrl.sdkQueryInProgress = false;
              androidLiveScanCtrl.noSdkSnapshot = !data.installed_sdks; // Will show/hide view elements depending on data returned

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
