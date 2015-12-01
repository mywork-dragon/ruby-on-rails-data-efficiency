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
      getAndroidSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/scan_android_sdks',
          params: {appId: appId}
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
      androidHiddenLiveScanAnalytics: function(platform, appId, displayStatus) {

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {
          appData = data;

          if(platform == 'android') {
            /* -------- Mixpanel Analytics Start -------- */
            if(displayStatus != 'normal') {
              mixpanel.track(
                "Hidden SDK Live Scan Viewed", {
                  'appName': appData.name,
                  'companyName': appData.company.name,
                  'appId': appData.id,
                  'displayStatus': displayStatus
                }
              );
            }
            /* -------- Mixpanel Analytics End -------- */
          }

        });

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

          var mixpanelEventTitle = "";
          var liveScanSlacktivityColor = "";

          if(sdkData.errorCode == 0) {
            mixpanelEventTitle = "SDK Live Scan Success";
            liveScanSlacktivityColor = "#45825A";
          } else if(sdkData.errorCode == 2 || sdkData.errorCode > 5) {
            mixpanelEventTitle = "SDK Live Scan Status Error";
            liveScanSlacktivityColor = "#A45200";
          } else {
            mixpanelEventTitle = "SDK Live Scan Failed";
            liveScanSlacktivityColor = "#E82020";
          }
          var sdkCompanies = Object.keys(sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys(sdkData.sdkOpenSource).toString();
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            mixpanelEventTitle, {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkCompanies': sdkCompanies,
              'sdkOpenSource': sdkOpenSource,
              'lastUpdated': sdkData.lastUpdated,
              'errorCode': sdkData.errorCode,
              'errorMessage': sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": mixpanelEventTitle,
            "fallback": mixpanelEventTitle,
            "color": liveScanSlacktivityColor,
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'lastUpdated': sdkData.lastUpdated,
            'errorCode': sdkData.errorCode,
            'errorMessage': sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      androidLiveScanFailRequestAnalytics: function(platform, appId, errorStatus, errorCode) {

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
            "SDK Live Scan Failed", {
              'companyName': appData.company.name,
              'appName': appData.name,
              'appId': appData.id,
              'errorStatus': errorStatus,
              'errorCode': errorCode
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "SDK Live Scan Failed",
            "fallback": "SDK Live Scan Failed",
            "color": "#E82020",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'errorStatus': errorStatus,
            'errorCode': errorCode
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

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

          var sdkCompanies = Object.keys(sdkData.installed_sdk_companies).toString();
          var sdkOpenSource = Object.keys(sdkData.installed_open_source_sdks).toString();
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Success", {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkCompanies': sdkCompanies,
              'sdkOpenSource': sdkOpenSource,
              'lastUpdated': sdkData.lastUpdated
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "SDK Live Scan Success",
            "fallback": "SDK Live Scan Success",
            "color": "#45825A",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
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
            "SDK Live Scan Failed", {
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
            "title": "SDK Live Scan Failed",
            "fallback": "SDK Live Scan Failed",
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
            "Hidden SDK Live Scan Viewed", {
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
