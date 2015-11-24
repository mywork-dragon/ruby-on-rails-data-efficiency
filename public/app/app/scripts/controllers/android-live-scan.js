'use strict';

angular.module('appApp').controller("AndroidLiveScanCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "authService", "appDataService", "sdkLiveScanService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, authService, appDataService, sdkLiveScanService) {

    var androidLiveScanCtrl = this;

    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    $scope.$on('EVENT_ON_APP_DETAILS_LOAD_COMPLETION', function() {

      androidLiveScanCtrl.appData = appDataService.appData; // Service to share data between both controllers
      androidLiveScanCtrl.displayStatus = appDataService.appData.displayStatus;

      sdkLiveScanService.checkForAndroidSdks(androidLiveScanCtrl.appData.id)
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
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "App Page Viewed", {
              "appId": $routeParams.id,
              "appName": androidLiveScanCtrl.appData.name,
              "companyName": androidLiveScanCtrl.appData.company.name,
              "appPlatform": APP_PLATFORM
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          if($routeParams.platform == 'android') {
            /* -------- Mixpanel Analytics Start -------- */
            if(androidLiveScanCtrl.displayStatus != 'normal') {
              mixpanel.track(
                "Hidden SDK Live Scan Viewed", {
                  "userEmail": userInfo.email,
                  'appName': androidLiveScanCtrl.appData.name,
                  'companyName': androidLiveScanCtrl.appData.company.name,
                  'appId': androidLiveScanCtrl.appData.id,
                  'displayStatus': androidLiveScanCtrl.displayStatus
                }
              );
            }
            /* -------- Mixpanel Analytics End -------- */
          }
        }).error(function(err) {
        });

    });

    androidLiveScanCtrl.getSdks = function(appId) {

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "SDK Live Scan Clicked", {
          'companyName': androidLiveScanCtrl.appData.company.name,
          'appName': androidLiveScanCtrl.appData.name,
          'appId': androidLiveScanCtrl.appData.id,
          'mobilePriority': androidLiveScanCtrl.appData.mobilePriority,
          'fortuneRank': androidLiveScanCtrl.appData.company.fortuneRank,
          'userBase': androidLiveScanCtrl.appData.userBase,
          'ratingsAllCount': androidLiveScanCtrl.appData.ratingsCount
        }
      );
      /* -------- Mixpanel Analytics End -------- */
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
          var mixpanelEventTitle = "";
          var liveScanSlacktivityColor = "";

          if(androidLiveScanCtrl.sdkData.errorCode == 0) {
            mixpanelEventTitle = "SDK Live Scan Success";
            liveScanSlacktivityColor = "#45825A";
          } else if(androidLiveScanCtrl.sdkData.errorCode == 2 || androidLiveScanCtrl.sdkData.errorCode > 5) {
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
              'appName': androidLiveScanCtrl.appData.name,
              'companyName': androidLiveScanCtrl.appData.company.name,
              'appId': androidLiveScanCtrl.appData.id,
              'sdkCompanies': androidLiveScanCtrl.sdkData.sdkCompanies,
              'sdkOpenSource': androidLiveScanCtrl.sdkData.sdkOpenSource,
              'uninstalledSdkCompanies': androidLiveScanCtrl.sdkData.uninstalledSdkCompanies,
              'uninstalledSdkOpenSource': androidLiveScanCtrl.sdkData.uninstalledSdkOpenSource,
              'lastUpdated': androidLiveScanCtrl.sdkData.lastUpdated,
              'errorCode': androidLiveScanCtrl.sdkData.errorCode,
              'errorMessage': androidLiveScanCtrl.sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var sdkCompanies = Object.keys(androidLiveScanCtrl.sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys(androidLiveScanCtrl.sdkData.sdkOpenSource).toString();
          var uninstalledSdkCompanies = Object.keys(androidLiveScanCtrl.sdkData.uninstalledSdkCompanies).toString();
          var uninstalledSdkOpenSource = Object.keys(androidLiveScanCtrl.sdkData.uninstalledSdkOpenSource).toString();
          var slacktivityData = {
            "title": mixpanelEventTitle,
            "fallback": mixpanelEventTitle,
            "color": liveScanSlacktivityColor,
            "userEmail": userInfo.email,
            'appName': androidLiveScanCtrl.appData.name,
            'companyName': androidLiveScanCtrl.appData.company.name,
            'appId': androidLiveScanCtrl.appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'uninstalledSdkCompanies': uninstalledSdkCompanies,
            'uninstalledSdkOpenSource': uninstalledSdkOpenSource,
            'lastUpdated': androidLiveScanCtrl.sdkData.lastUpdated,
            'errorCode': androidLiveScanCtrl.sdkData.errorCode,
            'errorMessage': androidLiveScanCtrl.sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        }).error(function(err, status) {
          androidLiveScanCtrl.sdkQueryInProgress = false;
          androidLiveScanCtrl.noSdkSnapshot = false;
          androidLiveScanCtrl.noSdkData = true;
          androidLiveScanCtrl.sdkData = {'errorMessage': "Error - Please Try Again Later"};
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Failed", {
              'companyName': androidLiveScanCtrl.appData.company.name,
              'appName': androidLiveScanCtrl.appData.name,
              'appId': androidLiveScanCtrl.appData.id,
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
            'appName': androidLiveScanCtrl.appData.name,
            'companyName': androidLiveScanCtrl.appData.company.name,
            'appId': androidLiveScanCtrl.appData.id,
            'errorStatus': status
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        });
    };

    androidLiveScanCtrl.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };
  }
]);
