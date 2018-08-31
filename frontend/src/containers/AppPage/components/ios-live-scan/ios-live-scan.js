import angular from 'angular';
import $ from 'jquery';
import { calculateDaysAgo } from 'utils/format.utils';

angular
  .module('appApp')
  .controller('IosLiveScanCtrl', IosLiveScanCtrl);

IosLiveScanCtrl.$inject = [
  'loggitService',
  'sdkLiveScanService',
  '$interval',
  '$timeout',
  '$stateParams',
];

function IosLiveScanCtrl (
  loggitService,
  sdkLiveScanService,
  $interval,
  $timeout,
  $stateParams,
) {
  const iosLiveScanCtrl = this;

  iosLiveScanCtrl.iosAppId = null;
  iosLiveScanCtrl.sdkLiveScanPageLoading = true; // on initial page load

  // Bound functions
  iosLiveScanCtrl.calculateDaysAgo = calculateDaysAgo;
  iosLiveScanCtrl.checkForIosSdks = checkForIosSdks;
  iosLiveScanCtrl.getSdks = getSdks;

  activate();

  function activate () {
    iosLiveScanCtrl.iosAppId = $stateParams.id;
    checkForIosSdks($stateParams.id);
  }

  function checkForIosSdks (appId, calledAfterSuccess) {
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
          // Failed analytics response - MixPanel & Slacktivity
          sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($stateParams.platform, iosLiveScanCtrl.iosAppId, data.error_code, errorCodeMessages[data.error_code]);
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
      .error(() => {
        iosLiveScanCtrl.sdkLiveScanPageLoading = false;
      });
  }

  function getSdks () {
    // Reset all view-changing vars
    iosLiveScanCtrl.sdkQueryInProgress = true;
    iosLiveScanCtrl.failedLiveScan = false;
    iosLiveScanCtrl.sdkData = null;
    iosLiveScanCtrl.hideLiveScanButton = false;
    iosLiveScanCtrl.scanStatusPercentage = 5; // default percentage for Validating

    sdkLiveScanService.startIosSdkScan(iosLiveScanCtrl.iosAppId)
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
  }

  function notify (type) {
    switch (type) {
      case 'data-unchanged':
        return loggitService.log('App has not changed since last scan. SDKs are currently up to date!');
      case 'updated':
        return loggitService.logSuccess('SDKs up to date!');
      case 'timeout':
        return loggitService.logError("We're sorry, something went wrong. Please refresh the page and try again.")
    }
  }

  function pullScanStatus () {
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

    const interval = $interval(() => {
      sdkLiveScanService.getIosScanStatus(iosLiveScanCtrl.scanJobId)
        .success((data) => {
          intervalCount++;

          // Reset 'query in progress' if pulling times out
          if (intervalCount === numRepeat) {
            iosLiveScanCtrl.sdkQueryInProgress = false;
            notify('timeout');
            sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosLiveScanCtrl.iosAppId, -1); // Failed analytics response - MixPanel & Slacktivity
          }

          if (!data.status && data.status !== 0) { data.status = 11; } // If status is null, treat as failed (status 10)

          iosLiveScanCtrl.scanStatusMessage = statusCodeMessages[data.status]; // Sets scan status message

          switch (data.status) {
            case 0:
              iosLiveScanCtrl.scanStatusPercentage = 5;
              break;
            case 1:
              notify('data-unchanged');
              iosLiveScanCtrl.checkForIosSdks(iosLiveScanCtrl.iosAppId, true); // Loads new sdks on page
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
              notify('updated');
              iosLiveScanCtrl.sdkLiveScanPageLoading = true;
              $timeout(() => {
                iosLiveScanCtrl.checkForIosSdks(iosLiveScanCtrl.iosAppId, true);
              }, 5000);
              break;
            case 11:
              iosLiveScanCtrl.noSdkData = true;
              iosLiveScanCtrl.failedLiveScan = true;

              if (iosLiveScanCtrl.errorCodeMessage != null) {
                iosLiveScanCtrl.scanErrorMessage = iosLiveScanCtrl.errorCodeMessage;
              } else {
                iosLiveScanCtrl.scanErrorMessage = 'Error - Please Try Again';
                // Failed analytics response - MixPanel & Slacktivity
                sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosLiveScanCtrl.iosAppId, data.status);
              }
              break;
          }

          if ([2, 3, 4, 6].includes(data.status)) {
            $interval.cancel(interval); // Exits interval loop

            // Run for any qualifying status
            iosLiveScanCtrl.sdkQueryInProgress = false;
            iosLiveScanCtrl.noSdkData = false;
            iosLiveScanCtrl.errorCodeMessage = statusCodeMessages[data.status];
            iosLiveScanCtrl.sdkData = { errorCode: -1 };

            if (data.status < 4) {
              iosLiveScanCtrl.hideLiveScanButton = true;
              // Failed analytics response - MixPanel & Slacktivity
              sdkLiveScanService.iosLiveScanHiddenSdksAnalytics($stateParams.platform, iosLiveScanCtrl.iosAppId, data.status, statusCodeMessages[data.status]);
            } else if (data.status === 4) {
              iosLiveScanCtrl.hideLiveScanButton = true;
              sdkLiveScanService.iosLiveScanFailRequestAnalytics($stateParams.platform, iosLiveScanCtrl.iosAppId, data.status);
            }
          } else if ([1, 10, 11].includes(data.status)) {
            $interval.cancel(interval); // Exits interval loop

            // Run for any qualifying status
            iosLiveScanCtrl.sdkQueryInProgress = false;
          }
        })
        .error(() => {
          iosLiveScanCtrl.failedLiveScan = true;
        });
    }, msDelay, numRepeat);
  }
}
