'use strict';

angular.module("appApp")
  .factory("sdkLiveScanService", ['$http', function($http) {
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
          data: {id: appId}
        })
      },
      getIosScanStatus: function(statusId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/ios_scan_status',
          params: {id: statusId}
        })
      }
    };
  }]);
