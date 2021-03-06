import angular from 'angular';
import $ from 'jquery';

angular.module('appApp').controller('AndroidLiveScanCtrl', ['$scope', '$http', '$stateParams', '$window', 'pageTitleService', 'listApiService', 'loggitService', '$rootScope', 'apiService', 'authService', 'sdkLiveScanService', '$interval', '$timeout',
  function($scope, $http, $stateParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, sdkLiveScanService, $interval, $timeout) {
    const androidLiveScanCtrl = this;
    const androidAppId = $stateParams.id;

    androidLiveScanCtrl.notify = function (type) {
      switch (type) {
        case 'data-unchanged':
          return loggitService.logSuccess('App has not changed since last scan. SDKs are currently up to date!');
        case 'updated':
          return loggitService.logSuccess('SDKs up to date!');
      }
    };

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; } catch (err) {}
    };

    androidLiveScanCtrl.calculateDaysAgo = function(date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0]; // returns '5 days' for example
    };

    androidLiveScanCtrl.checkForAndroidSdks = function(appId, calledAfterSuccess) {
      sdkLiveScanService.checkForAndroidSdks(appId)
        .success((data) => {
          let allowLiveScanData = {appAvailable: $scope.appAvailable, liveScanEnabled: data.live_scan_enabled};
          androidLiveScanCtrl.sdkData = {
            installedSdks: data.installed_sdks,
            uninstalledSdks: data.uninstalled_sdks,
            installedSdksCount: data.installed_sdks_count,
            uninstalledSdksCount: data.uninstalled_sdks_count,
            lastUpdated: data.updated,
            errorCode: data.error_code,
            liveScanEnabled: sdkLiveScanService.allowLiveScan(allowLiveScanData),
          };

          androidLiveScanCtrl.noSdkData = false;
          androidLiveScanCtrl.sdkLiveScanPageLoading = false;

          if (data == null) {
            androidLiveScanCtrl.noSdkData = true;
            androidLiveScanCtrl.sdkData = { errorCodeMessage: 'Error - Please Try Again Later' };
          }

          androidLiveScanCtrl.noSdkSnapshot = !data.installed_sdks.length && !data.uninstalled_sdks.length;

          const errorCodeMessages = [
            "Sorry, Live Scan Not Available - App is Not Available in Any Google Play Store We're Scanning", // taken down
            "Sorry, Live Scan Not Available - App is Not Available in Any Google Play Store We're Scanning", // foreign
            'Sorry, Live Scan Not Available for Paid Apps', // paid app
          ];

          if (data.error_code != null) {
            androidLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
            sdkLiveScanService.androidLiveScanHiddenSdksAnalytics($stateParams.platform, androidAppId, data.error_code, errorCodeMessages[data.error_code]); // Failed analytics response - MixPanel & Slacktivity
          }

          androidLiveScanCtrl.liveScanUnavailableMsg = "Live Scan Temporarily Unavailable";
          if (!$scope.appAvailable) {
            androidLiveScanCtrl.liveScanUnavailableMsg = "Live Scan Unavailable";
          }

          // LS Success Analytics - MixPanel & Slacktivity
          if (calledAfterSuccess) {
            sdkLiveScanService.androidLiveScanSuccessRequestAnalytics($stateParams.platform, appId, androidLiveScanCtrl.sdkData);
          }

          /* Initializes all Bootstrap tooltips */
          $timeout(() => {
            $(() => { $('[data-toggle="tooltip"]').tooltip(); });
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
        .success((data) => {
          androidLiveScanCtrl.scanJobId = data.job_id;
          androidLiveScanCtrl.scanStatusMessage = 'Preparing...';
          androidLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating
          pullScanStatus();
        })
        .error(() => {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.failedLiveScan = true;
        });
    };

    // Helper method for getSdks() method - 4min timeout (2s * 120)
    var pullScanStatus = function() {
      const msDelay = 2000;
      const numRepeat = 120;
      let intervalCount = 0;

      // Messages that correspond to (status == index number)
      const statusCheckStatusCodeMessages = [
        'Preparing...',
        'Downloading...',
        'Scanning...',
        'Complete',
        'Sorry, Live Scan Failed. Please Try Again Later',
        'Sorry, SDKs Temporarily Not Available for This App',
        'Sorry, SDKs Not Available for Paid Apps',
        'App data has not changed since last scan. Currently up-to-date.',
      ];

      var interval = $interval(() => {
        sdkLiveScanService.getAndroidScanStatus(androidLiveScanCtrl.scanJobId)
          .success((data) => {
            intervalCount++;

            let statusCode = data.status;

            // Reset 'query in progress' if polling times out
            if (intervalCount == numRepeat) {
              androidLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.androidLiveScanFailRequestAnalytics($stateParams.platform, androidAppId, -1, 'Timeout'); // Failed analytics response - MixPanel & Slacktivity
            }

            if (!statusCode && statusCode !== 0) { statusCode = 4; } // If status is null, treat as failed (status 4)

            const statusMessage = statusCheckStatusCodeMessages[statusCode];

            androidLiveScanCtrl.scanStatusMessage = statusMessage; // Sets scan status message

            switch (data.status) {
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
                androidLiveScanCtrl.notify('updated');
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
                androidLiveScanCtrl.sdkData = { errorCode: data.status };
                androidLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.androidLiveScanFailRequestAnalytics($stateParams.platform, androidAppId, statusCode, statusMessage); // Failed analytics response - MixPanel & Slacktivity
                break;
              case 7: // unchanged
                androidLiveScanCtrl.noSdkData = false;
                $interval.cancel(interval); // Exits interval loop

                androidLiveScanCtrl.sdkQueryInProgress = false;
                androidLiveScanCtrl.errorCodeMessage = statusMessage;

                androidLiveScanCtrl.checkForAndroidSdks(androidAppId);
                androidLiveScanCtrl.hideLiveScanButton = false;
                sdkLiveScanService.androidLiveScanUnchangedVersionSuccess($stateParams.platform, androidAppId);
                androidLiveScanCtrl.notify('data-unchanged');
                break;
            }
          })
          .error(() => {
            androidLiveScanCtrl.failedLiveScan = true;
          });
      }, msDelay, numRepeat);
    };
  }]);
