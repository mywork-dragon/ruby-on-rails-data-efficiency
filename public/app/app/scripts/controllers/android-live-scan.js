'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "authService", "sdkLiveScanService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, authService, sdkLiveScanService) {

    var androidLiveScanCtrl = this;
    var androidAppId = $routeParams.id;

    sdkLiveScanService.checkForAndroidSdks(androidAppId)
      .success(function(data) {
        var sdkErrorMessage = "";
        androidLiveScanCtrl.noSdkData = false;
        if(data == null) {
          androidLiveScanCtrl.noSdkData = true;
          androidLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"}
        }
        if(data.error_code > 0) {
          androidLiveScanCtrl.noSdkData = true;
          switch (data.error_code) {
            case 1:
              sdkErrorMessage = "No SDKs in App";
              break;
            case 2:
              sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
              androidLiveScanCtrl.displayStatus = "taken_down";
              break;
            case 3:
              sdkErrorMessage = "Error - Please Try Again";
              break;
            case 4:
              sdkErrorMessage = "SDKs Not Available for Paid Apps";
              break;
            case 5:
              androidLiveScanCtrl.noSdkData = false;
              break;
            case 6:
              androidLiveScanCtrl.displayStatus = "device_incompatible";
              break;
            case 7:
              androidLiveScanCtrl.displayStatus = "foreign";
              break;
          }
        }
        androidLiveScanCtrl.sdkData = {
          'sdkCompanies': data.installed_sdk_companies,
          'sdkOpenSource': data.installed_open_source_sdks,
          'uninstalledSdkCompanies': data.uninstalled_sdk_companies,
          'uninstalledSdkOpenSource': data.uninstalled_open_source_sdks,
          'lastUpdated': data.updated,
          'errorCode': data.error_code,
          'errorMessage': sdkErrorMessage
        };
        if(androidLiveScanCtrl.isEmpty(data.installed_sdk_companies) && androidLiveScanCtrl.isEmpty(data.installed_open_source_sdks) && androidLiveScanCtrl.isEmpty(data.uninstalled_sdk_companies) && androidLiveScanCtrl.isEmpty(data.uninstalled_open_source_sdks)) {
          androidLiveScanCtrl.noSdkSnapshot = true;
        }

        // Hidden SDK LS MixPanel & Slacktivity
        sdkLiveScanService.hiddenLiveScanAnalytics($routeParams.platform, androidAppId, androidLiveScanCtrl.displayStatus);

      }).error(function(err) {
      });

    androidLiveScanCtrl.getSdks = function(appId) {
      androidLiveScanCtrl.sdkQueryInProgress = true;
      sdkLiveScanService.getAndroidSdks(appId)
        .success(function(data) {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          var sdkErrorMessage = "";
          androidLiveScanCtrl.noSdkData = false;
          if(data == null) {
            androidLiveScanCtrl.noSdkData = true;
            androidLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"}
          }
          if(data.error_code > 0) {
            androidLiveScanCtrl.noSdkData = true;
            switch (data.error_code) {
              case 1:
                sdkErrorMessage = "No SDKs in App";
                break;
              case 2:
                sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
                androidLiveScanCtrl.displayStatus = "taken_down";
                break;
              case 3:
                sdkErrorMessage = "Error - Please Try Again";
                break;
              case 4:
                sdkErrorMessage = "SDKs Not Available for Paid Apps";
                break;
              case 5:
                androidLiveScanCtrl.noSdkData = false;
                break;
              case 6:
                androidLiveScanCtrl.displayStatus = "device_incompatible";
                break;
              case 7:
                androidLiveScanCtrl.displayStatus = "foreign";
                break;
            }
          }
          if(data) {
            androidLiveScanCtrl.sdkData = {
              'sdkCompanies': data.installed_sdk_companies,
              'sdkOpenSource': data.installed_open_source_sdks,
              'uninstalledSdkCompanies': data.uninstalled_sdk_companies,
              'uninstalledSdkOpenSource': data.uninstalled_open_source_sdks,
              'lastUpdated': data.updated,
              'errorCode': data.error_code,
              'errorMessage': sdkErrorMessage
            };
          }

          // Successful SDK LS MixPanel & Slacktivity
          sdkLiveScanService.liveScanSuccessRequestAnalytics($routeParams.platform, androidAppId, androidLiveScanCtrl.sdkData);

        }).error(function(err, status) {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.noSdkData = true;
          androidLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"};

          // Failed SDK LS MixPanel & Slacktivity
          sdkLiveScanService.liveScanFailRequestAnalytics($routeParams.platform, androidAppId, status);

        });
    };

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };
  }
]);
