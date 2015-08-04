'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "authService", "authToken", "listApiService", "$rootScope", "$route", "pageTitleService",
    function ($scope, $location, authService, authToken, listApiService, $rootScope, $route, pageTitleService) {

      $scope.$route = $route; // for use in determining active tab (for CSS styling)

      $scope.pageTitleService = pageTitleService;

      $scope.checkIfOwnPage = function() {

        return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

      };

      $scope.isAuthenticated = authToken.isAuthenticated();

      /* Login specific logic */
      $scope.onLoginButtonClick = function() {

        authService.login($scope.userEmail, $scope.userPassword).then(function(){
          $scope.isAuthenticated = authToken.isAuthenticated();
          listApiService.getLists().success(function(data) {
            $rootScope.usersLists = data;
          });
            location.reload();
        },
        function(){
          alert('Incorrect Email or Password');
        });
      };

      $scope.logUserOut = authToken.deleteToken;

      $rootScope.$on('STRING_REPRESENTS_EVENT_FAILURE_TIMEOUT', function() {
        authToken.deleteToken();
      });

      authService.permissions()
        .success(function(data) {
          $scope.canViewSupportDesk = data.can_view_support_desk;
          $scope.canViewAdSpend = data.can_view_ad_spend;
          $scope.canViewSdks = data.can_view_sdks;
        })
        .error(function() {
          $scope.canViewSupportDesk = false;
          $scope.canViewAdSpend = true;
          $scope.canViewSdks = false;
        });

  }])
  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope",
    function($scope, apiService, $http, $rootScope) {

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "Page Viewed",
        { "pageType": "Search",
          "userauthenticated": $scope.isAuthenticated,
          "appPlatform": APP_PLATFORM }
      );
      /* -------- Mixpanel Analytics End -------- */

      /* Initializes all Bootstrap tooltips */
      $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      });

      $scope.mixpanelAnalyticsEventTooltip = function(name) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Tooltip Viewed",
          { "tooltipName": name }
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      if(!$rootScope.tags) $rootScope.tags = [];

      $scope.onFilterChange = function(parameter, value, displayName, limitToOneFilter) {

        /* -------- Mixpanel Analytics Start -------- */
        var mixpanelProperties = {};
        mixpanelProperties['parameter'] = parameter;
        mixpanelProperties[parameter] = value;
        mixpanel.track(
          "Filter Added",
          mixpanelProperties
        );
        /* -------- Mixpanel Analytics End -------- */

        var duplicateTag = false;
        var oneTagUpdated = false;

        $rootScope.tags.forEach(function (tag) {

          // Determine if tag is a duplicate
          if (tag.parameter == parameter && tag.value == value) {
            duplicateTag = true;
          }

          if(limitToOneFilter && !duplicateTag) {
            // If replacing pre existing tag of limitToOneFilter = true category
            if (tag.parameter == parameter) {
              tag.value = value;
              tag.text = displayName + ': ' + value;
              oneTagUpdated = true;
            }
          }
        });

        if(limitToOneFilter && !duplicateTag && !oneTagUpdated) {
          // If first tag of limitToOneFilter = true category
          $rootScope.tags.push({
            parameter: parameter,
            value: value,
            text: displayName + ': ' + value
          });
        }

        if(!limitToOneFilter && !duplicateTag || $rootScope.tags.length < 1) {
          $rootScope.tags.push({
            parameter: parameter,
            value: value,
            text: displayName + ': ' + value
          });
        }
        $scope[parameter] = ""; // Resets HTML select on view to default option
      };
    }
  ])
  .controller("TableCtrl", ["$scope", "apiService", "listApiService", "$filter", "$rootScope", "loggitService", "AppPlatform",
    function($scope, apiService, listApiService, $filter, $rootScope, loggitService, AppPlatform) {
      return $rootScope.apps = [],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.appPlatform = AppPlatform,
        $scope.appsDisplayedCount = function() {
          var lastPageMaxApps = $rootScope.numPerPage * $rootScope.currentPage;
          var baseAppNum = $rootScope.numPerPage * ($rootScope.currentPage - 1) + 1;
          if (lastPageMaxApps > $rootScope.numApps) {
            return "" + baseAppNum + " - " + $rootScope.numApps;
          } else {
            return "" + baseAppNum + " - " + lastPageMaxApps;
          }
        },
        listApiService.getLists().success(function(data) {
          $rootScope.usersLists = data;
        }),
        $rootScope.selectedAppsForList = [],
        $scope.addSelectedTo = function(list, selectedApps) {
          listApiService.addSelectedTo(list, selectedApps, $scope.appPlatform.platform).success(function() {
            $scope.notify('add-selected-success');
            $rootScope.selectedAppsForList = [];
          }).error(function() {
            $scope.notify('add-selected-error');
          });
          $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
        },
        $scope.notify = function(type) {
          switch (type) {
            case "add-selected-success":
              return loggitService.logSuccess("Items were added successfully.");
            case "add-selected-error":
              return loggitService.logError("Error! Something went wrong while adding to list.");
          }
        },
        $scope.onFilterChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1, $scope.row = "";
        },
        $scope.onNumPerPageChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1;
        },
        $scope.onOrderChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1;
        },
        $scope.search = function() {
          return $scope.filteredApps = $filter("filter")($scope.apps, $scope.searchKeywords), $scope.onFilterChange();
        },
        $scope.numPerPageOpt = [100, 200, 350, 1000],
        $rootScope.numPerPage = $scope.numPerPageOpt[0],
        $rootScope.currentPage = 1,
        $scope.currentPageApps = []
    }
  ]);
