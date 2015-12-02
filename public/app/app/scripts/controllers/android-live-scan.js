'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "authService", "sdkLiveScanService", "appDataService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, authService, sdkLiveScanService, appDataService) {

    var androidLiveScanCtrl = this;
    var androidAppId = $routeParams.id;

    $scope.$on('APP_DATA_FOR_APP_DATA_SERVICE_SET', function() {
      // If display status is correct, change ctrl value
      if(appDataService.displayStatus.appId == $routeParams.id) {
        androidLiveScanCtrl.displayStatus = appDataService.displayStatus.status;
        console.log('$$$$', 'Display Updated by Service');
      }
    });

    if(appDataService.displayStatus.appId == $routeParams.id) {
      androidLiveScanCtrl.displayStatus = appDataService.displayStatus.status;
      console.log('$$$$', 'Display Updated by Service');
    } else {
      androidLiveScanCtrl.displayStatus = "normal"; // default, shows LS button
      console.log('$$$$', 'Display Set to Normal');
    }

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
              sdkErrorMessage = "Sorry, SDKs Not Available - App Removed from Google Play";
              androidLiveScanCtrl.displayStatus = "taken_down";
              break;
            case 3:
              sdkErrorMessage = "Error - Please Try Again";
              break;
            case 4:
              sdkErrorMessage = "Sorry, SDKs Not Available for Paid Apps";
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
        if(androidLiveScanCtrl.displayStatus != 'normal') {
          sdkLiveScanService.androidHiddenLiveScanAnalytics($routeParams.platform, androidAppId, androidLiveScanCtrl.displayStatus);
        }

      }).error(function(err) {
      });

    androidLiveScanCtrl.getSdks = function() {
      androidLiveScanCtrl.sdkQueryInProgress = true;

      // Reset data for new scan
      androidLiveScanCtrl.sdkData = {};
      if(androidLiveScanCtrl.sdkData.errorMessage) {
        androidLiveScanCtrl.sdkData.errorMessage = "";
      }

      sdkLiveScanService.getAndroidSdks(androidAppId)
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

            if(data.error_code == 3 || data.error_code == 4) { // If error, but doesn't hide L.S. button
              sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, sdkErrorMessage || androidLiveScanCtrl.displayStatus, data.error_code);
            } else if(data.error_code == 2 || data.error_code > 5) { // If error & hides L.S. button
              sdkLiveScanService.androidHiddenLiveScanAnalytics($routeParams.platform, androidAppId, androidLiveScanCtrl.displayStatus);

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
          if(data.error_code === 0 || data.error_code == 1) {
            sdkLiveScanService.androidLiveScanSuccessRequestAnalytics($routeParams.platform, androidAppId, androidLiveScanCtrl.sdkData);
          }

        }).error(function(err, status) {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.noSdkData = true;
          androidLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"};

          // Failed SDK LS MixPanel & Slacktivity
          sdkLiveScanService.androidLiveScanFailRequestAnalytics($routeParams.platform, androidAppId, status);

        });
    };

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };
  }
]);
