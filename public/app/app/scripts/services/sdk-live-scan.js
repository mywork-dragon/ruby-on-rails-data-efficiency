'use strict';

angular.module("appApp")
  .factory("sdkLiveScanService", ['$http', 'authService', function($http, authService) {
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

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          var sdkInstalls = sdkData.sdkCompanies;
          var sdkUninstalls = sdkData.sdkOpenSource;
          sdkInstalls = sdkInstalls && (sdkInstalls.length > 0) ? sdkInstalls.map(function(sdk) { return sdk.name; }) : '';
          sdkUninstalls = sdkUninstalls && (sdkUninstalls.length > 0) ? sdkUninstalls.map(function(sdk) { return sdk.name; }) : '';

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Android Live Scan Success", {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkInstalls': sdkInstalls,
              'sdkUninstalls': sdkUninstalls,
              'lastUpdated': sdkData.lastUpdated
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "Android Live Scan Success",
            "fallback": "Android Live Scan Success",
            "color": "#45825A",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkInstalls': sdkInstalls,
            'sdkUninstalls': sdkUninstalls,
            'lastUpdated': sdkData.lastUpdated
          };

          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      androidLiveScanFailRequestAnalytics: function(platform, appId, statusCode) {

        var errorMessage = "";

        if(statusCode == 4) {
          errorMessage = "Error (status 4)"
        } else if(statusCode == -1) {
          errorMessage = "Timeout"
        }

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

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
              'companyName': appData.company.name,
              'appName': appData.name,
              'appId': appData.id,
              'error': errorMessage,
              'statusCode': statusCode

            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "Android Live Scan Failed",
            "fallback": "Android Live Scan Failed",
            "color": "#E82020",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'error': errorMessage,
            'statusCode': statusCode
          };

          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
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
              'companyName': appData.company.name,
              'appId': appData.id,
              'statusCode': statusCode,
              'displayStatus': statusMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        });
      },
      iosLiveScanSuccessRequestAnalytics: function(platform, appId, sdkData) {

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          appData = data;

          var sdkInstalls = sdkData.installedSdks;
          sdkInstalls.map(function(sdk) { return sdk.name; });

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "iOS Live Scan Success", {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkInstalls': sdkInstalls,
              'lastUpdated': sdkData.lastUpdated
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "iOS Live Scan Success",
            "fallback": "iOS Live Scan Success",
            "color": "#45825A",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkInstalls': sdkInstalls,
            'lastUpdated': sdkData.lastUpdated
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      iosLiveScanFailRequestAnalytics: function(platform, appId, statusCode) {

        var errorMessage = "";

        if(statusCode == 11) {
          errorMessage = "Error (status 11)"
        } else if(statusCode == -1) {
          errorMessage = "Timeout"
        }

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {
          appData = data;
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "iOS Live Scan Failed", {
              'companyName': appData.company.name,
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
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'error': errorMessage,
            'statusCode': statusCode
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
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
              'companyName': appData.company.name,
              'appId': appData.id,
              'statusCode': statusCode,
              'displayStatus': statusMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        });
      }
    };
  }]);
