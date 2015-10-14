'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService) {

  // User info set
  var userInfo = {};
  authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

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
        }).error(function(err) {
        });
    });
  };

  $scope.appPlatform = $routeParams.platform;

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

  $scope.notify = function(type) {
    switch (type) {
      case "add-selected-success":
        return loggitService.logSuccess("Items were added successfully.");
      case "add-selected-error":
        return loggitService.logError("Error! Something went wrong while adding to list.");
    }
  };

  $scope.load();

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
        /* -------- Mixpanel Analytics Start -------- */
        var mixpanelEventTitle = "SDK Live Scan " + ($scope.sdkData.errorCode != 3 ? 'Success' : 'Failed');
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
          "color": mixpanelEventTitle == "SDK Live Scan Success" ? "#45825A" : "#E82020",
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
        if (API_URI_BASE.indexOf('52.7.134.183') >= 0) { slacktivityData['channel'] = 'staging-slacktivity' } // if on staging server
        window.Slacktivity.send(slacktivityData);
        /* -------- Slacktivity Alerts End -------- */
      }).error(function(err, status) {
        $scope.sdkQueryInProgress = false;
        $scope.noSdkData = true;
        $scope.sdkData = {'errorMessage': "Error - Please Try Again Later"};
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "SDK Live Scan Failed", {
            'companyName': $scope.appData.company.name,
            'appName': $scope.appData.name,
            'appId': $scope.appData.id,
            'errorStatus': err
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        /* -------- Slacktivity Alerts -------- */
        var slacktivityData = {
          "title": "SDK Live Scan Failed",
          "fallback": "SDK Live Scan Failed",
          "color": "#e82020",
          "userEmail": userInfo.email,
          'appName': $scope.appData.name,
          'companyName': $scope.appData.company.name,
          'appId': $scope.appData.id,
          'errorStatus': status
        };
        if (API_URI_BASE.indexOf('52.7.134.183') >= 0) { slacktivityData['channel'] = 'staging-slacktivity' } // if on staging server
        window.Slacktivity.send(slacktivityData);
        /* -------- Slacktivity Alerts End -------- */
      });
  };

  authService.permissions()
    .success(function(data) {
      $scope.canViewSupportDesk = data.can_view_support_desk;
    })
    .error(function() {
      $scope.canViewSupportDesk = false;
    });

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

  $scope.isEmpty = function(obj) {
    try { return Object.keys(obj).length === 0; }
    catch(err) {}
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
