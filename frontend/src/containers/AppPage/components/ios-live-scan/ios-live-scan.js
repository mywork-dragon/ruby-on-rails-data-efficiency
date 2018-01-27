import angular from 'angular';
import $ from 'jquery';

angular.module('appApp').controller('IosLiveScanCtrl', ['$scope', '$http', '$window', 'pageTitleService', 'listApiService', 'loggitService', '$rootScope', 'apiService', 'authService', 'sdkLiveScanService', '$interval', '$timeout', '$stateParams',
  function($scope, $http, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, sdkLiveScanService, $interval, $timeout, $stateParams) {
    const iosLiveScanCtrl = this;
    const iosAppId = $stateParams.id;

    iosLiveScanCtrl.notify = function (type) {
      switch (type) {
        case 'data-unchanged':
          return loggitService.log('App has not changed since last scan. SDKs are currently up to date!');
        case 'updated':
          return loggitService.logSuccess('SDKs up to date!');
      }
    };

    iosLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; } catch (err) {}
    };

    iosLiveScanCtrl.calculateDaysAgo = function(date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0]; // returns '5 days' for example
    };

    // Takes an array and number of slices as params, splits into two
    const splitArray = function(a, n) {
      const len = a.length;
      const out = [];
      let i = 0;
      while (i < len) {
        const size = Math.ceil((len - i) / n--);
        out.push(a.slice(i, i + size));
        i += size;
      }
      return out;
    };

    iosLiveScanCtrl.checkForIosSdks = function(appId, calledAfterSuccess) {
      sdkLiveScanService.checkForIosSdks(appId)
        .success((data) => {
          iosLiveScanCtrl.sdkData = {
            installedSdks: data.installed_sdks,
            uninstalledSdks: data.uninstalled_sdks,
            installedSdksCount: data.installed_sdks_count,
            uninstalledSdksCount: data.uninstalled_sdks_count,
            lastUpdated: data.updated,
            errorCode: data.error_code,
            liveScanEnabled: data.live_scan_enabled,
          };

          iosLiveScanCtrl.noSdkData = false;
          iosLiveScanCtrl.sdkLiveScanPageLoading = false;

          if (data == null) {
            iosLiveScanCtrl.noSdkData = true;
            iosLiveScanCtrl.sdkData = { errorCodeMessage: 'Error - Please Try Again Later' };
          }

          iosLiveScanCtrl.noSdkSnapshot = !data.installed_sdks.length && !data.uninstalled_sdks.length;

          const errorCodeMessages = [
            'Sorry, Live Scan Not Available for Paid Apps',
            "Sorry, Live Scan Not Available - App is Not Available in Any App Store We're Scanning",
            'Sorry, Live Scan Temporarily Not Available for This App',
            'Sorry, Live Scan Not Available for iPad Apps',
            'Sorry, Live Scan Not Available for Mac App',
          ];

          if (data.error_code != null) {
            iosLiveScanCtrl.errorCodeMessage = errorCodeMessages[data.error_code];
            sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($stateParams.platform, iosAppId, data.error_code, errorCodeMessages[data.error_code]); // Failed analytics response - MixPanel & Slacktivity
          }

          // LS Success Analytics - MixPanel & Slacktivity
          if (calledAfterSuccess) {
            sdkLiveScanService.iosLiveScanSuccessRequestAnalytics($stateParams.platform, appId, iosLiveScanCtrl.sdkData);
          }

          /* Initializes all Bootstrap tooltips */
          $timeout(() => {
            $(() => { $('[data-toggle="tooltip"]').tooltip(); });
          }, 1000);
        })
        .error((error) => {
          iosLiveScanCtrl.sdkLiveScanPageLoading = false;
        });
    };

    iosLiveScanCtrl.sdkLiveScanPageLoading = true; // on initial page load
    iosLiveScanCtrl.checkForIosSdks(iosAppId); // Call for initial SDKs load

    iosLiveScanCtrl.getSdks = function() {
      // Reset all view-changing vars
      iosLiveScanCtrl.sdkQueryInProgress = true;
      iosLiveScanCtrl.failedLiveScan = false;
      iosLiveScanCtrl.sdkData = null;
      iosLiveScanCtrl.hideLiveScanButton = false;
      iosLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating

      sdkLiveScanService.startIosSdkScan(iosAppId)
        .success((data) => {
          iosLiveScanCtrl.scanJobId = data.job_id;
          iosLiveScanCtrl.scanStatusMessage = 'Validating...';
          iosLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating
          pullScanStatus();
        })
        .error(() => {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
          iosLiveScanCtrl.failedLiveScan = true;
        });
    };

    // Helper method for getSdks() method
    var pullScanStatus = function() {
      const msDelay = 3000;
      const numRepeat = 180;
      let intervalCount = 0;

      // Messages that correspond to (status == index number)
      const statusCodeMessages = [
        'Validating...', // Non-terminating
        'Unchanged', // Unchanged
        "Sorry, SDKs Not Available - App is Not Available in Any App Store We're Scanning", // Not Available
        'Sorry, SDKs Not Available for Paid Apps', // Paid App
        'Sorry, SDKs Temporarily Not Available for This App', // Device incompatible
        'Preparing...', // Non-terminating
        'All Devices Currently In Use - Please Try Again.', // Device busy
        'Downloading...', // Non-terminating
        'Retrying...', // Non-terminating
        'Scanning...', // Non-terminating
        'Complete', // Complete
        'Failed', // Failed
      ];

      var interval = $interval(() => {
        sdkLiveScanService.getIosScanStatus(iosLiveScanCtrl.scanJobId)
          .success((data) => {
            intervalCount++;

            // Reset 'query in progress' if pulling times out
            if (intervalCount == numRepeat) {
              iosLiveScanCtrl.sdkQueryInProgress = false;
              sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosAppId, -1); // Failed analytics response - MixPanel & Slacktivity
            }

            if (!data.status && data.status !== 0) { data.status = 11; } // If status is null, treat as failed (status 10)

            iosLiveScanCtrl.scanStatusMessage = statusCodeMessages[data.status]; // Sets scan status message

            switch (data.status) {
              case 0:
                iosLiveScanCtrl.scanStatusPercentage = 5;
                break;
              case 1:
                iosLiveScanCtrl.notify('data-unchanged');
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
                iosLiveScanCtrl.notify('updated');
                iosLiveScanCtrl.checkForIosSdks(iosAppId, true, 10); // Loads new sdks on page
                break;
              case 11:
                iosLiveScanCtrl.noSdkData = true;
                iosLiveScanCtrl.failedLiveScan = true;

                if (iosLiveScanCtrl.errorCodeMessage != null) {
                  iosLiveScanCtrl.scanErrorMessage = iosLiveScanCtrl.errorCodeMessage;
                } else {
                  iosLiveScanCtrl.scanErrorMessage = "Error - Please Try Again";
                  sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosAppId, data.status); // Failed analytics response - MixPanel & Slacktivity
                }

                break;
            }

            // If status 2, 3 or 4
            if ((data.status >= 2 && data.status <= 4) || data.status == 6) {
              $interval.cancel(interval); // Exits interval loop

              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
              iosLiveScanCtrl.noSdkData = false;
              iosLiveScanCtrl.errorCodeMessage = statusCodeMessages[data.status];
              iosLiveScanCtrl.sdkData = { errorCode: -1 };

              if (data.status < 4) {
                iosLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($stateParams.platform, iosAppId, data.status, statusCodeMessages[data.status]); // Failed analytics response - MixPanel & Slacktivity
              } else if (data.status == 4) {
                iosLiveScanCtrl.hideLiveScanButton = true;
                sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosAppId, data.status); // Failed anal
              }
            } else if (data.status == 1 || data.status == 10 || data.status == 11) { // if status 1, 9 or 10
              $interval.cancel(interval); // Exits interval loop

              // Run for any qualifying status
              iosLiveScanCtrl.sdkQueryInProgress = false;
            }
          })
          .error(() => {
            iosLiveScanCtrl.failedLiveScan = true;
          });
      }, msDelay, numRepeat);
    };
  },

]);
