'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService) {

    var appDetailsCtrl = this;

    $scope.appPlatform = $routeParams.platform;

    // User info set
    var userInfo = {};
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

    $scope.load = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
        params: {id: $routeParams.id}
      }).success(function(data) {
        $scope.appData = data;

        /* Sets html title attribute */
        pageTitleService.setTitle($scope.appData.name);

        apiService.checkForSdks($scope.appData.id)
          .success(function(data) {
            var sdkErrorMessage = "";
            $scope.noSdkData = false;
            if(data == null) {
              $scope.noSdkData = true;
              $scope.sdkData = {'errorMessage': "Error - Please Try Again Later"}
            }
            if(data.error_code > 0) {
              $scope.noSdkData = true;
              switch (data.error_code) {
                case 1:
                  sdkErrorMessage = "No SDKs in App";
                  break;
                case 2:
                  sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
                  $scope.appData.displayStatus = "taken_down";
                  break;
                case 3:
                  sdkErrorMessage = "Error - Please Try Again";
                  break;
                case 4:
                  sdkErrorMessage = "SDKs Not Available for Paid Apps";
                  break;
                case 5:
                  $scope.noSdkData = false;
                  break;
                case 6:
                  $scope.appData.displayStatus = "device_incompatible";
                  break;
                case 7:
                  $scope.appData.displayStatus = "foreign";
                  break;
              }
            }
            $scope.sdkData = {
              'sdkCompanies': data.installed_sdk_companies,
              'sdkOpenSource': data.installed_open_source_sdks,
              'uninstalledSdkCompanies': data.uninstalled_sdk_companies,
              'uninstalledSdkOpenSource': data.uninstalled_open_source_sdks,
              'lastUpdated': data.updated,
              'errorCode': data.error_code,
              'errorMessage': sdkErrorMessage
            };
            if($scope.isEmpty(data.installed_sdk_companies) && $scope.isEmpty(data.installed_open_source_sdks) && $scope.isEmpty(data.uninstalled_sdk_companies) && $scope.isEmpty(data.uninstalled_open_source_sdks)) {
              $scope.noAppSnapshot = true;
            }
            /* -------- Mixpanel Analytics Start -------- */
            mixpanel.track(
              "App Page Viewed", {
                "appId": $routeParams.id,
                "appName": $scope.appData.name,
                "companyName": $scope.appData.company.name,
                "appPlatform": APP_PLATFORM
              }
            );
            /* -------- Mixpanel Analytics End -------- */
            if($routeParams.platform == 'android') {
              /* -------- Mixpanel Analytics Start -------- */
              if($scope.appData.displayStatus != 'normal') {
                mixpanel.track(
                  "Hidden SDK Live Scan Viewed", {
                    "userEmail": userInfo.email,
                    'appName': $scope.appData.name,
                    'companyName': $scope.appData.company.name,
                    'appId': $scope.appData.id,
                    'displayStatus': $scope.appData.displayStatus
                  }
                );
              }
              /* -------- Mixpanel Analytics End -------- */
            }
          }).error(function(err) {
          });
      });
    };

    $scope.load();

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      var linkedinLink = "";

      if (linkedinLinkType == 'company') {
        linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.appData.company.name);
      } else {
        linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.appData.company.name) + "+" + linkedinLinkType;
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": $scope.appData.company.name,
          "companyPosition": linkedinLinkType
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink);
    };

    $scope.linkTo = function(path) {
      $window.location.href = path;
    };

    $scope.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
      }
    };

    $scope.addSelectedTo = function(list) {
      var selectedApp = [{
        id: $routeParams.id,
        type: $routeParams.platform == 'IosApp' ? 'ios' : 'android'
      }];
      listApiService.addSelectedTo(list, selectedApp, $scope.appPlatform).success(function() {
        $scope.notify('add-selected-success');
        $rootScope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error');
      });
      $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.getSdks = function(appId) {

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "SDK Live Scan Clicked", {
          'companyName': $scope.appData.company.name,
          'appName': $scope.appData.name,
          'appId': $scope.appData.id,
          'mobilePriority': $scope.appData.mobilePriority,
          'fortuneRank': $scope.appData.company.fortuneRank,
          'userBase': $scope.appData.userBase,
          'ratingsAllCount': $scope.appData.ratingsCount
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      $scope.sdkQueryInProgress = true;
      apiService.getSdks(appId, 'api/scan_android_sdks')
        .success(function(data) {
          $scope.sdkQueryInProgress = false;
          $scope.noAppSnapshot = false;
          var sdkErrorMessage = "";
          $scope.noSdkData = false;
          if(data == null) {
            $scope.noSdkData = true;
            $scope.sdkData = {'errorMessage': "Error - Please Try Again Later"}
          }
          if(data.error_code > 0) {
            $scope.noSdkData = true;
            switch (data.error_code) {
              case 1:
                sdkErrorMessage = "No SDKs in App";
                break;
              case 2:
                sdkErrorMessage = "SDKs Not Available - App Removed from Google Play";
                $scope.appData.displayStatus = "taken_down";
                break;
              case 3:
                sdkErrorMessage = "Error - Please Try Again";
                break;
              case 4:
                sdkErrorMessage = "SDKs Not Available for Paid Apps";
                break;
              case 5:
                $scope.noSdkData = false;
                break;
              case 6:
                $scope.appData.displayStatus = "device_incompatible";
                break;
              case 7:
                $scope.appData.displayStatus = "foreign";
                break;
            }
          }
          if(data) {
            $scope.sdkData = {
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

          if($scope.sdkData.errorCode == 0) {
            mixpanelEventTitle = "SDK Live Scan Success";
            liveScanSlacktivityColor = "#45825A";
          } else if($scope.sdkData.errorCode == 2 || $scope.sdkData.errorCode > 5) {
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
              'appName': $scope.appData.name,
              'companyName': $scope.appData.company.name,
              'appId': $scope.appData.id,
              'sdkCompanies': $scope.sdkData.sdkCompanies,
              'sdkOpenSource': $scope.sdkData.sdkOpenSource,
              'uninstalledSdkCompanies': $scope.sdkData.uninstalledSdkCompanies,
              'uninstalledSdkOpenSource': $scope.sdkData.uninstalledSdkOpenSource,
              'lastUpdated': $scope.sdkData.lastUpdated,
              'errorCode': $scope.sdkData.errorCode,
              'errorMessage': $scope.sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var sdkCompanies = Object.keys($scope.sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys($scope.sdkData.sdkOpenSource).toString();
          var uninstalledSdkCompanies = Object.keys($scope.sdkData.uninstalledSdkCompanies).toString();
          var uninstalledSdkOpenSource = Object.keys($scope.sdkData.uninstalledSdkOpenSource).toString();
          var slacktivityData = {
            "title": mixpanelEventTitle,
            "fallback": mixpanelEventTitle,
            "color": liveScanSlacktivityColor,
            "userEmail": userInfo.email,
            'appName': $scope.appData.name,
            'companyName': $scope.appData.company.name,
            'appId': $scope.appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'uninstalledSdkCompanies': uninstalledSdkCompanies,
            'uninstalledSdkOpenSource': uninstalledSdkOpenSource,
            'lastUpdated': $scope.sdkData.lastUpdated,
            'errorCode': $scope.sdkData.errorCode,
            'errorMessage': $scope.sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        }).error(function(err, status) {
          $scope.sdkQueryInProgress = false;
          $scope.noAppSnapshot = false;
          $scope.noSdkData = true;
          $scope.sdkData = {'errorMessage': "Error - Please Try Again Later"};
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Failed", {
              'companyName': $scope.appData.company.name,
              'appName': $scope.appData.name,
              'appId': $scope.appData.id,
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
            'appName': $scope.appData.name,
            'companyName': $scope.appData.company.name,
            'appId': $scope.appData.id,
            'errorStatus': status
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        });
    };

    $scope.exportContactsToCsv = function() {
      apiService.exportContactsToCsv($scope.companyContacts, $scope.appData.company.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');

          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    /* Company Contacts Logic */
    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;
    $scope.getCompanyContacts = function(websites, filter) {
      $scope.contactsLoading = true;
      apiService.getCompanyContacts(websites, filter)
        .success(function(data) {
          $scope.companyContacts = data.contacts;
          $scope.contactsLoading = false;
          $scope.contactsLoaded = true;
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Company Contacts Requested", {
              'websites': websites,
              'companyName': $scope.appData.company.name,
              'requestResults': data.contacts,
              'requestResultsCount': data.contacts.length,
              'titleFilter': filter || ''
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        }).error(function(err) {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Company Contacts Requested", {
              'websites': websites,
              'companyName': $scope.appData.company.name,
              'requestError': err,
              'titleFilter': filter || ''
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          $scope.contactsLoading = false;
          $scope.contactsLoaded = false;
        });
    };
  }
]);
