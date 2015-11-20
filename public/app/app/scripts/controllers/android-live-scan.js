'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService) {

    var iosLiveScanCtrl = this;

    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    // ------------------------------------------------------------------------------------------------
    apiService.checkForSdks($scope.$parent.appData.id)
      .success(function(data) {
        var sdkErrorMessage = "";
        iosLiveScanCtrl.noSdkData = false;
        if(data == null) {
          iosLiveScanCtrl.noSdkData = true;
          iosLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"}
        }
        if(data.error_code > 0) {
          iosLiveScanCtrl.noSdkData = true;
          switch (data.error_code) {
            case 1:
              sdkErrorMessage = "No SDKs in App";
              break;
            case 2:
              sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
              // ------------------------------------------------------------------------------------------------
              $scope.$parent.appData.displayStatus = "taken_down";
              break;
            case 3:
              sdkErrorMessage = "Error - Please Try Again";
              break;
            case 4:
              sdkErrorMessage = "SDKs Not Available for Paid Apps";
              break;
            case 5:
              iosLiveScanCtrl.noSdkData = false;
              break;
            case 6:
              // ------------------------------------------------------------------------------------------------
              $scope.$parent.appData.displayStatus = "device_incompatible";
              break;
            case 7:
              // ------------------------------------------------------------------------------------------------
              $scope.$parent.appData.displayStatus = "foreign";
              break;
          }
        }
        iosLiveScanCtrl.sdkData = {
          'sdkCompanies': data.installed_sdk_companies,
          'sdkOpenSource': data.installed_open_source_sdks,
          'uninstalledSdkCompanies': data.uninstalled_sdk_companies,
          'uninstalledSdkOpenSource': data.uninstalled_open_source_sdks,
          'lastUpdated': data.updated,
          'errorCode': data.error_code,
          'errorMessage': sdkErrorMessage
        };
        if(iosLiveScanCtrl.isEmpty(data.installed_sdk_companies) && iosLiveScanCtrl.isEmpty(data.installed_open_source_sdks) && iosLiveScanCtrl.isEmpty(data.uninstalled_sdk_companies) && iosLiveScanCtrl.isEmpty(data.uninstalled_open_source_sdks)) {
          iosLiveScanCtrl.noSdkSnapshot = true;
        }
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "App Page Viewed", {
            "appId": $routeParams.id,
            "appName": $scope.$parent.appData.name,
            "companyName": $scope.$parent.appData.company.name,
            "appPlatform": APP_PLATFORM
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        if($routeParams.platform == 'android') {
          /* -------- Mixpanel Analytics Start -------- */
          // ------------------------------------------------------------------------------------------------
          if($scope.$parent.appData.displayStatus != 'normal') {
            mixpanel.track(
              "Hidden SDK Live Scan Viewed", {
                "userEmail": userInfo.email,
                // ------------------------------------------------------------------------------------------------
                'appName': $scope.$parent.appData.name,
                'companyName': $scope.$parent.appData.company.name,
                'appId': $scope.$parent.appData.id,
                'displayStatus': $scope.$parent.appData.displayStatus
              }
            );
          }
          /* -------- Mixpanel Analytics End -------- */
        }
      }).error(function(err) {
      });

    iosLiveScanCtrl.getSdks = function(appId) {

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "SDK Live Scan Clicked", {
          'companyName': $scope.$parent.appData.company.name,
          'appName': $scope.$parent.appData.name,
          'appId': $scope.$parent.appData.id,
          'mobilePriority': $scope.$parent.appData.mobilePriority,
          'fortuneRank': $scope.$parent.appData.company.fortuneRank,
          'userBase': $scope.$parent.appData.userBase,
          'ratingsAllCount': $scope.$parent.appData.ratingsCount
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      iosLiveScanCtrl.sdkQueryInProgress = true;
      apiService.getSdks(appId, 'api/scan_android_sdks')
        .success(function(data) {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
          var sdkErrorMessage = "";
          iosLiveScanCtrl.noSdkData = false;
          if(data == null) {
            iosLiveScanCtrl.noSdkData = true;
            iosLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"}
          }
          if(data.error_code > 0) {
            iosLiveScanCtrl.noSdkData = true;
            switch (data.error_code) {
              case 1:
                sdkErrorMessage = "No SDKs in App";
                break;
              case 2:
                sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
                // ------------------------------------------------------------------------------------------------
                $scope.$parent.appData.displayStatus = "taken_down";
                break;
              case 3:
                sdkErrorMessage = "Error - Please Try Again";
                break;
              case 4:
                sdkErrorMessage = "SDKs Not Available for Paid Apps";
                break;
              case 5:
                iosLiveScanCtrl.noSdkData = false;
                break;
              case 6:
                // ------------------------------------------------------------------------------------------------
                $scope.$parent.appData.displayStatus = "device_incompatible";
                break;
              case 7:
                // ------------------------------------------------------------------------------------------------
                $scope.$parent.appData.displayStatus = "foreign";
                break;
            }
          }
          if(data) {
            iosLiveScanCtrl.sdkData = {
              'sdkCompanies': data.installed_sdk_companies,
              'sdkOpenSource': data.installed_open_source_sdks,
              'uninstalledSdkCompanies': data.uninstalled_sdk_companies,
              'uninstalledSdkOpenSource': data.uninstalled_open_source_sdks,
              'lastUpdated': data.updated,
              'errorCode': data.error_code,
              'errorMessage': sdkErrorMessage
            };
          }
          var mixpanelEventTitle = "";
          var liveScanSlacktivityColor = "";

          if(iosLiveScanCtrl.sdkData.errorCode == 0) {
            mixpanelEventTitle = "SDK Live Scan Success";
            liveScanSlacktivityColor = "#45825A";
          } else if(iosLiveScanCtrl.sdkData.errorCode == 2 || iosLiveScanCtrl.sdkData.errorCode > 5) {
            mixpanelEventTitle = "SDK Live Scan Hidden";
            liveScanSlacktivityColor = "#A45200";
          } else {
            mixpanelEventTitle = "SDK Live Scan Failed";
            liveScanSlacktivityColor = "#E82020";
          }
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            mixpanelEventTitle, {
              'platform': 'Android',
              // ------------------------------------------------------------------------------------------------
              'appName': $scope.$parent.appData.name,
              'companyName': $scope.$parent.appData.company.name,
              'appId': $scope.$parent.appData.id,
              'sdkCompanies': iosLiveScanCtrl.sdkData.sdkCompanies,
              'sdkOpenSource': iosLiveScanCtrl.sdkData.sdkOpenSource,
              'uninstalledSdkCompanies': iosLiveScanCtrl.sdkData.uninstalledSdkCompanies,
              'uninstalledSdkOpenSource': iosLiveScanCtrl.sdkData.uninstalledSdkOpenSource,
              'lastUpdated': iosLiveScanCtrl.sdkData.lastUpdated,
              'errorCode': iosLiveScanCtrl.sdkData.errorCode,
              'errorMessage': iosLiveScanCtrl.sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var sdkCompanies = Object.keys(iosLiveScanCtrl.sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys(iosLiveScanCtrl.sdkData.sdkOpenSource).toString();
          var uninstalledSdkCompanies = Object.keys(iosLiveScanCtrl.sdkData.uninstalledSdkCompanies).toString();
          var uninstalledSdkOpenSource = Object.keys(iosLiveScanCtrl.sdkData.uninstalledSdkOpenSource).toString();
          var slacktivityData = {
            "title": mixpanelEventTitle,
            "fallback": mixpanelEventTitle,
            "color": liveScanSlacktivityColor,
            "userEmail": userInfo.email,
            // ------------------------------------------------------------------------------------------------
            'appName': $scope.$parent.appData.name,
            'companyName': $scope.$parent.appData.company.name,
            'appId': $scope.$parent.appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'uninstalledSdkCompanies': uninstalledSdkCompanies,
            'uninstalledSdkOpenSource': uninstalledSdkOpenSource,
            'lastUpdated': iosLiveScanCtrl.sdkData.lastUpdated,
            'errorCode': iosLiveScanCtrl.sdkData.errorCode,
            'errorMessage': iosLiveScanCtrl.sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        }).error(function(err, status) {
          iosLiveScanCtrl.sdkQueryInProgress = false;
          iosLiveScanCtrl.noSdkSnapshot = false;
          iosLiveScanCtrl.noSdkData = true;
          iosLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"};
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Failed", {
              // ------------------------------------------------------------------------------------------------
              'companyName': $scope.$parent.appData.company.name,
              'appName': $scope.$parent.appData.name,
              'appId': $scope.$parent.appData.id,
              'errorStatus': status
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "SDK Live Scan Failed",
            "fallback": "SDK Live Scan Failed",
            "color": "#E82020",
            "userEmail": userInfo.email,
            // ------------------------------------------------------------------------------------------------
            'appName': $scope.$parent.appData.name,
            'companyName': $scope.$parent.appData.company.name,
            'appId': $scope.$parent.appData.id,
            'errorStatus': status
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        });
    };

    iosLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };
  }
]);
