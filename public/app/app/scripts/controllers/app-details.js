'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService",
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService) {

  $scope.load = function() {

    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.appData = data;

      /* Sets html title attribute */
      pageTitleService.setTitle($scope.appData.name);

      console.log('APP ID', $scope.appData.id);

      apiService.checkForSdks($scope.appData.id)
        .success(function(data) {
          var sdkErrorMessage = "";
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
                sdkErrorMessage = "Error - Please Try Again Later";
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
            'sdks': data.sdks,
            'lastUpdated': data.last_updated,
            'errorCode': data.error_code,
            'errorMessage': sdkErrorMessage
          };
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
        'companyName': $scope.appData.company.name
      }
    );
    /* -------- Mixpanel Analytics End -------- */

    $scope.sdkQueryInProgress = true;
    apiService.getSdks(appId, 'api/scan_android_sdks')
      .success(function(data) {
        $scope.sdkQueryInProgress = false;
        var sdkErrorMessage = "";
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
              sdkErrorMessage = "Error - Please Try Again Later";
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
            'sdks': data.sdks,
            'lastUpdated': data.last_updated,
            'errorCode': data.error_code,
            'errorMessage': sdkErrorMessage
          };
        }
      }).error(function() {
        $scope.sdkQueryInProgress = false;
        $scope.noSdkData = true;
        $scope.sdkData = {'errorMessage': "Error - Please Try Again Later"}
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

  /* -------- Mixpanel Analytics Start -------- */
  mixpanel.track(
    "Page Viewed", {
      "pageType": "App",
      "appid": $routeParams.id,
      "appPlatform": APP_PLATFORM
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
