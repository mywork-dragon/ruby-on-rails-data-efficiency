'use strict';

angular.module("appApp")
  .factory("sdkLiveScanService", ['$http', 'slacktivity', function($http, slacktivity) {
    return {
      checkForAndroidSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/android_sdks_exist',
          params: {appId: appId}
        })
      },
      startAndroidSdkScan: function(appId) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/android_start_scan',
          data: {appId: appId}
        })
      },
      getAndroidScanStatus: function(statusJobId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/android_scan_status',
          params: {jobId: statusJobId}
        })
      },
      checkForIosSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/ios_sdks_exist',
          params: {appId: appId}
        })
      },
      startIosSdkScan: function(appId) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/ios_start_scan',
          data: {appId: appId}
        })
      },
      getIosScanStatus: function(statusJobId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/ios_scan_status',
          params: {jobId: statusJobId}
        })
      },
      androidLiveScanSuccessRequestAnalytics: function(platform, appId, sdkData) {

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          var sdkInstalls = sdkData.sdkCompanies;
          var sdkUninstalls = sdkData.sdkOpenSource;
          sdkInstalls = sdkInstalls && (sdkInstalls.length > 0) ? sdkInstalls.map(function(sdk) { return sdk.name; }).join(', ') : '';
          sdkUninstalls = sdkUninstalls && (sdkUninstalls.length > 0) ? sdkUninstalls.map(function(sdk) { return sdk.name; }).join(', ') : '';

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Android Live Scan Success", {
              'platform': platform,
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'availableIn': appData.regions,
              'isInternational': appData.isInternational,
              'sdkInstalls': sdkInstalls,
              'sdkUninstalls': sdkUninstalls,
              'lastUpdated': sdkData.lastUpdated
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          if (appData.isInternational) {
            var slacktivityData = {
              "title": "International Android Live Scan Success",
              "fallback": "International Android Live Scan Success",
              "color": "#45825A",
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'availableIn': appData.regions.join(', '),
              'sdkInstalls': sdkInstalls,
              'sdkUninstalls': sdkUninstalls,
              'lastUpdated': sdkData.lastUpdated
            };
            slacktivity.notifySlack(slacktivityData, true);
          }
        });

      },
      androidLiveScanFailRequestAnalytics: function(platform, appId, statusCode, statusMessage) {
        var color = "#E82020";

        if (statusCode == 3) {
          color = "#FFD94D"; // yellow
        }

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Android Live Scan Failed", {
              'companyName': (appData.publisher || {}).name,
              'appName': appData.name,
              'appId': appData.id,
              'availableIn': appData.regions,
              'isInternational': appData.isInternational,
              'statusCode': statusCode,
              'statusMessage' : statusMessage,
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "Android Live Scan Failed",
            "fallback": "Android Live Scan Failed",
            "color": color,
            'appName': appData.name,
            'companyName': (appData.publisher || {}).name,
            'appId': appData.id,
            'availableIn': appData.regions.join(', '),
            'isInternational': appData.isInternational,
            'statusCode': statusCode,
            'statusMessage' : statusMessage,
          };

          slacktivity.notifySlack(slacktivityData, true, '#automated-alerts');
          /* -------- Slacktivity Alerts End -------- */
        });

      },
      androidLiveScanHiddenSdksAnalytics: function(platform, appId, statusCode, statusMessage) {

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Hidden Android Live Scan Viewed", {
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'statusCode': statusCode,
              'displayStatus': statusMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        });
      },
      androidLiveScanUnchangedVersionSuccess: function(platform, appId) {
        var errorMessage = "";

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {
          appData = data;
        })
      },
      iosLiveScanSuccessRequestAnalytics: function(platform, appId, sdkData) {

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          var countryCodes = appData.appStores.availableIn.map(function(x) {
            return x.country_code
          })
          var sdkInstalls = sdkData.installed_sdks;
          var sdkUninstalls = sdkData.uninstalled_sdks;
          sdkInstalls = sdkInstalls && (sdkInstalls.length > 0) ? sdkInstalls.map(function(sdk) { return sdk.name; }).join(', ') : '';
          sdkUninstalls = sdkUninstalls && (sdkUninstalls.length > 0) ? sdkUninstalls.map(function(sdk) { return sdk.name; }).join(', ') : '';
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "iOS Live Scan Success", {
              'platform': platform,
              'availableIn': countryCodes,
              'isInternational': appData.isInternational,
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'sdkInstalls': sdkInstalls,
              'sdkUninstalls': sdkUninstalls,
              'lastUpdated': sdkData.lastUpdated
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          if (isInternational) {
            var slacktivityData = {
              "title": "International iOS Live Scan Success",
              "fallback": "International iOS Live Scan Success",
              "color": "#45825A",
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'availableIn': countryCodes.join(', '),
              'sdkInstalls': sdkInstalls,
              'sdkUninstalls': sdkUninstalls,
              'lastUpdated': sdkData.lastUpdated
            };
            slacktivity.notifySlack(slacktivityData, true);
          }
        });

      },
      iosLiveScanFailRequestAnalytics: function(platform, appId, statusCode) {
        var errorMessage = "";

        if(statusCode == 11) {
          errorMessage = "Error (status 11)"
        } else if (statusCode == 4) {
          errorMessage = "Incompatible Device"
        } else if(statusCode == -1) {
          errorMessage = "Timeout"
        }

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {
          appData = data;
          var countryCodes = appData.appStores.availableIn.map(function(x) {
            return x.country_code
          })
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "iOS Live Scan Failed", {
              'companyName': (appData.publisher || {}).name,
              'availableIn': countryCodes,
              'isInternational': appData.isInternational,
              'appName': appData.name,
              'appId': appData.id,
              'error': errorMessage,
              'statusCode': statusCode

            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "iOS Live Scan Failed",
            "fallback": "iOS Live Scan Failed",
            "color": "#E82020",
            'appName': appData.name,
            'availableIn': countryCodes.join(', '),
            'isInternational': appData.isInternational,
            'companyName': (appData.publisher || {}).name,
            'appId': appData.id,
            'error': errorMessage,
            'statusCode': statusCode
          };
          slacktivity.notifySlack(slacktivityData, true, '#automated-alerts');
          /* -------- Slacktivity Alerts End -------- */
        });

      },
      iosLiveScanHiddenSdksAnalytics: function(platform, appId, statusCode, statusMessage) {

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Hidden iOS Live Scan Viewed", {
              'appName': appData.name,
              'companyName': (appData.publisher || {}).name,
              'appId': appData.id,
              'statusCode': statusCode,
              'displayStatus': statusMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        });
      },
      calculateDaysAgo: function(date, shortFormat) {
        /*
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        var firstDate = new Date(date);
        var secondDate = Date.now();
        var diffDays = Math.round(Math.abs((firstDate.getTime() - secondDate)/(oneDay)));
        return diffDays;
        */
        if (shortFormat) {
          moment.locale('en', {
              relativeTime : {
                  future: "in %s",
                  past:   "%s ago",
                  s:  "s",
                  m:  "1m",
                  mm: "%dm",
                  h:  "1h",
                  hh: "%dh",
                  d:  "1d",
                  dd: "%dd",
                  M:  "1mo",
                  MM: "%dmo",
                  y:  "1y",
                  yy: "%dy"
              }
          });
        }
        return moment(date).fromNow(); // JS library for human readable dates
      }
    };
  }]);
