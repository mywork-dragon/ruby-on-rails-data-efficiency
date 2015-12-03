'use strict';

angular.module('appApp').controller("IosLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "sdkLiveScanService", "$interval",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, sdkLiveScanService, $interval) {

    var iosLiveScanCtrl = this;
    var iosAppId = $routeParams.id;
    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    iosLiveScanCtrl.isEmpty = function(obj) {
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

    iosLiveScanCtrl.checkForIosSdks = function(appId, calledAfterSuccess) {

      sdkLiveScanService.checkForIosSdks(appId)
        .success(function (data) {
          var installedSdks = splitArray(data.installed_sdks, 2);
          iosLiveScanCtrl.sdkData = {
            'sdkCompanies': installedSdks[0],
            'sdkOpenSource': installedSdks[1],
            'lastUpdated': data.updated,
            'errorCode': data.error_code
          };

          iosLiveScanCtrl.noSdkData = false;

          if(data == null) {
            iosLiveScanCtrl.noSdkData = true;
            iosLiveScanCtrl.sdkData = {'errorCodeMessage': "Error - Please Try Again Later"};
          }

          iosLiveScanCtrl.noSdkSnapshot = !data.installed_sdks;

          var errorCodeMessages = [
            "Sorry, SDKs Not Available for Paid Apps",
            "Sorry, SDKs Not Available - App is Not in U.S. App Store",
            "Sorry, SDKs Temporarily Not Available for This App"
          ];

          if (data.error_code != null) {
            iosLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
            iosLiveScanCtrl.hideLiveScanButton = true;
            sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($routeParams.platform, iosAppId, data.error_code, errorCodeMessages[data.error_code]); // Failed analytics response - MixPanel & Slacktivity
          }

          // LS Success Analytics - MixPanel & Slacktivity
          if(calledAfterSuccess) {
            sdkLiveScanService.iosLiveScanSuccessRequestAnalytics($routeParams.platform, appId, data);
          }

        });

    };

    iosLiveScanCtrl.checkForIosSdks(iosAppId); // Call for initial SDKs load

    iosLiveScanCtrl.getSdks = function() {

      // Reset all view-changing vars
      iosLiveScanCtrl.sdkQueryInProgress = true;
      iosLiveScanCtrl.displayDataUnchangedStatus = false;
      iosLiveScanCtrl.failedLiveScan = false;
      iosLiveScanCtrl.errorCodeMessage = null;
      iosLiveScanCtrl.sdkData = null;
      iosLiveScanCtrl.hideLiveScanButton = false;
      iosLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating

      sdkLiveScanService.startIosSdkScan(iosAppId)
        .success(function(data) {
          iosLiveScanCtrl.scanJobId = data.job_id;
          iosLiveScanCtrl.scanStatusMessage = "Validating...";
          iosLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating
          pullScanStatus();
        })
        .error(function() {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
          iosLiveScanCtrl.failedLiveScan = true;
        });
    };

    // Helper method for getSdks() method
    var pullScanStatus = function() {
      var msDelay = 2000;
      var numRepeat = 120;
      var intervalCount = 0;

      // Messages that correspond to (status == index number)
      var statusCodeMessages = [
        "Validating...",                                            // Non-terminating
        "Unchanged",                                                // Unchanged
        "Sorry, SDKs Not Available - App is Not in U.S. App Store", // Not Available
        "Sorry, SDKs Not Available for Paid Apps",                  // Paid App
        "Sorry, SDKs Temporarily Not Available for This App",       // Device incompatible
        "Preparing...",                                             // Non-terminating
        "All Devices Currently In Use - Please Try Again.",         // Device busy
        "Downloading...",                                           // Non-terminating
        "Retrying...",                                              // Non-terminating
        "Scanning...",                                              // Non-terminating
        "Complete",                                                 // Complete
        "Failed"                                                    // Failed
      ];

      var interval = $interval(function() {
        sdkLiveScanService.getIosScanStatus(iosLiveScanCtrl.scanJobId)
          .success(function(data) {
            intervalCount++;

            // Reset 'query in progress' if pulling times out
            if(intervalCount == 120) {
              iosLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.iosLiveScanFailRequestAnalytics($routeParams.platform, iosAppId, -1); // Failed analytics response - MixPanel & Slacktivity
            }

            if(!data.status && data.status !== 0) { data.status = 11 } // If status is null, treat as failed (status 10)

            iosLiveScanCtrl.scanStatusMessage = statusCodeMessages[data.status]; // Sets scan status message

            switch(data.status) {
              case 0:
                iosLiveScanCtrl.scanStatusPercentage = 5;
                break;
              case 1:
                iosLiveScanCtrl.displayDataUnchangedStatus = true;
                iosLiveScanCtrl.checkForIosSdks(iosAppId, true); // Loads new sdks on page
                break;
              case 5:
                iosLiveScanCtrl.scanStatusPercentage = 10;
                break;
              case 7:
                iosLiveScanCtrl.scanStatusPercentage = 20;
                break;
              case 8:
                iosLiveScanCtrl.scanStatusPercentage = 50;
                break;
              case 9:
                iosLiveScanCtrl.scanStatusPercentage = 90;
                break;
              case 10:
                iosLiveScanCtrl.scanStatusPercentage = 100;
                iosLiveScanCtrl.noSdkData = false;
                iosLiveScanCtrl.checkForIosSdks(iosAppId, true, 10); // Loads new sdks on page
                break;
              case 11:
                iosLiveScanCtrl.noSdkData = true;
                iosLiveScanCtrl.failedLiveScan = true;
                sdkLiveScanService.iosLiveScanFailRequestAnalytics($routeParams.platform, iosAppId, 11); // Failed analytics response - MixPanel & Slacktivity
                break;
            }

            // If status 2, 3 or 4
            if((data.status >= 2 && data.status <= 4) || data.status == 6) {

              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
              iosLiveScanCtrl.noSdkData = false;
              iosLiveScanCtrl.errorCodeMessage = statusCodeMessages[data.status];
              iosLiveScanCtrl.sdkData = { 'errorCode': -1 };

              iosLiveScanCtrl.noSdkSnapshot = !data.installed_sdks; // Will show/hide view elements depending on data returned

              if(data.status != 6) {
                iosLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($routeParams.platform, iosAppId, data.status, statusCodeMessages[data.status]); // Failed analytics response - MixPanel & Slacktivity
              }

              $interval.cancel(interval); // Exits interval loop

            } else if(data.status == 1 || data.status == 10 || data.status == 11) { // if status 1, 9 or 10
              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
              iosLiveScanCtrl.noSdkSnapshot = !data.installed_sdks; // Will show/hide view elements depending on data returned

              $interval.cancel(interval); // Exits interval loop

            }
          })
          .error(function() {
            iosLiveScanCtrl.failedLiveScan = true;
          });

      }, msDelay, numRepeat);

    };

  }

]);
