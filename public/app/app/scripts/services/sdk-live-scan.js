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
      }
    };
  }]);
