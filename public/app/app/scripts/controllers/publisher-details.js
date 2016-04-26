'use strict';

angular.module('appApp').controller("PublisherDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService", "searchService", "uniqueStringsFilter",
  function($scope, $http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService, searchService, uniqueStringsFilter) {

    var publisherDetailsCtrl = this;
    $scope.appPlatform = $routeParams.platform
    $scope.initialPageLoadComplete = false; // shows page load spinner

    $scope.load = function(category, order) {

      publisherDetailsCtrl.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $scope.appPlatform + '_developer',
        params: {id: $routeParams.id, sortBy: category, orderBy: order}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        $scope.publisherData = data;
        $scope.publisherData.websites = uniqueStringsFilter($scope.publisherData.websites)
        $scope.apps = data.apps;
        $scope.numApps = data.apps.length;
        $rootScope.numApps = data.apps.length;
        publisherDetailsCtrl.queryInProgress = false;

        $scope.initialPageLoadComplete = true; // hides page load spinner

        /* Sets html title attribute */

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Publisher Page Viewed", {
            "publisherId": $routeParams.id,
            "appPlatform": $scope.appPlatform,
            "publisherName": $scope.publisherData.name
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        publisherDetailsCtrl.queryInProgress = false;
      });
    };
    $scope.load();

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      var linkedinLink = "";

      if (linkedinLinkType == 'company') {
        linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.publisherData.name);
      } else {
        linkedinLink = "https://www.linkedin.com/vsearch/p?keywords=" + linkedinLinkType + "&company=" + encodeURI($scope.publisherData.name);
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": $scope.publisherData.name,
          "companyPosition": linkedinLinkType
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink);
    };

    $scope.onAppTableAppClick = function(app) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "App on Company Page Clicked", {
          "companyName": $scope.publisherData.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      $window.location.href = "#/app/" + (app.type == 'IosApp' ? 'ios' : 'android') + "/" + app.id;
    };

    $scope.addMixedSelectedTo = function(list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
        $scope.notify('add-selected-success');
        $scope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error');
      });
      $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
      }
    };

    $scope.exportContactsToCsv = function() {
      apiService.exportContactsToCsv($scope.companyContacts, $scope.publisherData.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    $scope.getLastUpdatedDaysClass = function(lastUpdatedDays) {
      return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
    };

    // When orderby/sort arrows on dashboard table are clicked
    $scope.sortApps = function(category, order) {
      $scope.load(category, order);
    };

    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;
    $scope.getCompanyContacts = function(websites, filter) {
      $scope.contactsLoading = true;
      apiService.getCompanyContacts(websites, filter).success(function(data) {
        $scope.companyContacts = data.contacts;
        $scope.contactsLoading = false;
        $scope.contactsLoaded = true;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': $scope.publisherData.name,
            'requestResults': data.contacts,
            'requestResultsCount': data.contacts.length,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        $scope.contactsLoading = false;
        $scope.contactsLoaded = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'websites': websites,
            'companyName': $scope.publisherData.name,
            'requestResultsCount': 0,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      });
    };

  }
]);
