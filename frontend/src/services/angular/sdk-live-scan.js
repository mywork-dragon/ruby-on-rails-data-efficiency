import angular from 'angular';
import mixpanel from 'mixpanel-browser';
import moment from 'moment';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('sdkLiveScanService', ['$http', 'slacktivity', function($http, slacktivity) {
    return {
      checkForAndroidSdks (appId) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/android_sdks_exist`,
          params: { appId },
        });
      },
      startAndroidSdkScan(appId) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/android_start_scan`,
          data: { appId },
        });
      },
      getAndroidScanStatus(statusJobId) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/android_scan_status`,
          params: { jobId: statusJobId },
        });
      },
      checkForIosSdks(appId) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/ios_sdks_exist`,
          params: { appId },
        });
      },
      startIosSdkScan(appId) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/ios_start_scan`,
          data: { appId },
        });
      },
      getIosScanStatus(statusJobId) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/ios_scan_status`,
          params: { jobId: statusJobId },
        });
      },
      androidLiveScanSuccessRequestAnalytics(platform, appId, sdkData) {
        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;

          let sdkInstalls = sdkData.sdkCompanies;
          let sdkUninstalls = sdkData.sdkOpenSource;
          sdkInstalls = sdkInstalls && (sdkInstalls.length > 0) ? sdkInstalls.map(sdk => sdk.name).join(', ') : '';
          sdkUninstalls = sdkUninstalls && (sdkUninstalls.length > 0) ? sdkUninstalls.map(sdk => sdk.name).join(', ') : '';

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('Android Live Scan Success', {
            platform,
            appName: appData.name,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            availableIn: appData.regions,
            isInternational: appData.isInternational,
            sdkInstalls,
            sdkUninstalls,
            lastUpdated: sdkData.lastUpdated,
          });
          /* -------- Mixpanel Analytics End -------- */
          if (appData.isInternational) {
            const slacktivityData = {
              title: 'International Android Live Scan Success',
              fallback: 'International Android Live Scan Success',
              color: '#45825A',
              appName: appData.name,
              companyName: (appData.publisher || {}).name,
              appId: appData.id,
              availableIn: appData.regions.join(', '),
              sdkInstalls,
              sdkUninstalls,
              lastUpdated: sdkData.lastUpdated,
            };
            slacktivity.notifySlack(slacktivityData, true);
          }
        });
      },
      androidLiveScanFailRequestAnalytics(platform, appId, statusCode, statusMessage) {
        let color = '#E82020';

        if (statusCode === 3) {
          color = '#FFD94D'; // yellow
        }

        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('Android Live Scan Failed', {
            companyName: (appData.publisher || {}).name,
            appName: appData.name,
            appId: appData.id,
            availableIn: appData.regions,
            isInternational: appData.isInternational,
            statusCode,
            statusMessage,
          });
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          const slacktivityData = {
            title: 'Android Live Scan Failed',
            fallback: 'Android Live Scan Failed',
            color,
            appName: appData.name,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            availableIn: appData.regions.join(', '),
            isInternational: appData.isInternational,
            statusCode,
            statusMessage,
          };

          slacktivity.notifySlack(slacktivityData, true, '#automated-alerts');
          /* -------- Slacktivity Alerts End -------- */
        });
      },
      androidLiveScanHiddenSdksAnalytics(platform, appId, statusCode, statusMessage) {
        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('Hidden Android Live Scan Viewed', {
            appName: appData.name,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            statusCode,
            displayStatus: statusMessage,
          });
          /* -------- Mixpanel Analytics End -------- */
        });
      },
      androidLiveScanUnchangedVersionSuccess(platform, appId) {
        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;
        });
      },
      iosLiveScanSuccessRequestAnalytics(platform, appId, sdkData) {
        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;

          const countryCodes = appData.appStores.availableIn.map(x => x.country_code);
          let sdkInstalls = sdkData.installed_sdks;
          let sdkUninstalls = sdkData.uninstalled_sdks;
          sdkInstalls = sdkInstalls && (sdkInstalls.length > 0) ? sdkInstalls.map(sdk => sdk.name).join(', ') : '';
          sdkUninstalls = sdkUninstalls && (sdkUninstalls.length > 0) ? sdkUninstalls.map(sdk => sdk.name).join(', ') : '';
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('iOS Live Scan Success', {
            platform,
            availableIn: countryCodes,
            isInternational: appData.isInternational,
            appName: appData.name,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            sdkInstalls,
            sdkUninstalls,
            lastUpdated: sdkData.lastUpdated,
          });
          /* -------- Mixpanel Analytics End -------- */
          if (appData.isInternational) {
            const slacktivityData = {
              title: 'International iOS Live Scan Success',
              fallback: 'International iOS Live Scan Success',
              color: '#45825A',
              appName: appData.name,
              companyName: (appData.publisher || {}).name,
              appId: appData.id,
              availableIn: countryCodes.join(', '),
              sdkInstalls,
              sdkUninstalls,
              lastUpdated: sdkData.lastUpdated,
            };
            slacktivity.notifySlack(slacktivityData, true);
          }
        });
      },
      iosLiveScanFailRequestAnalytics(platform, appId, statusCode) {
        let errorMessage = '';

        if (statusCode === 11) {
          errorMessage = 'Error (status 11)';
        } else if (statusCode === 4) {
          errorMessage = 'Incompatible Device';
        } else if (statusCode === -1) {
          errorMessage = 'Timeout';
        }

        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;
          const countryCodes = appData.appStores.availableIn.map(x => x.country_code);
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('iOS Live Scan Failed', {
            companyName: (appData.publisher || {}).name,
            availableIn: countryCodes,
            isInternational: appData.isInternational,
            appName: appData.name,
            appId: appData.id,
            error: errorMessage,
            statusCode,

          });
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          const slacktivityData = {
            title: 'iOS Live Scan Failed',
            fallback: 'iOS Live Scan Failed',
            color: '#E82020',
            appName: appData.name,
            availableIn: countryCodes.join(', '),
            isInternational: appData.isInternational,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            error: errorMessage,
            statusCode,
          };
          slacktivity.notifySlack(slacktivityData, true, '#automated-alerts');
          /* -------- Slacktivity Alerts End -------- */
        });
      },
      iosLiveScanHiddenSdksAnalytics(platform, appId, statusCode, statusMessage) {
        let appData = {}; // Load app data
        $http({
          method: 'GET',
          url: `${API_URI_BASE}api/get_${platform}_app`,
          params: { id: appId },
        }).success((data) => {
          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track('Hidden iOS Live Scan Viewed', {
            appName: appData.name,
            companyName: (appData.publisher || {}).name,
            appId: appData.id,
            statusCode,
            displayStatus: statusMessage,
          });
          /* -------- Mixpanel Analytics End -------- */
        });
      },
      calculateDaysAgo(date, shortFormat) {
        /*
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        var firstDate = new Date(date);
        var secondDate = Date.now();
        var diffDays = Math.round(Math.abs((firstDate.getTime() - secondDate)/(oneDay)));
        return diffDays;
        */
        if (shortFormat) {
          moment.locale('en', {
            relativeTime: {
              future: 'in %s',
              past: '%s ago',
              s: 's',
              m: '1m',
              mm: '%dm',
              h: '1h',
              hh: '%dh',
              d: '1d',
              dd: '%dd',
              M: '1mo',
              MM: '%dmo',
              y: '1y',
              yy: '%dy',
            },
          });
        }
        return moment(date).fromNow(); // JS library for human readable dates
      },
      allowLiveScan(appAvailable, liveScanEnabled) {
        // This service can be extended to incorporate
        // the countries where the livescan is available
        // or any other parameter we need to add to the
        // livescan activation.
        return appAvailable && liveScanEnabled;
      }
    };
  }]);
