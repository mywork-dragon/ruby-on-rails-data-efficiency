'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "authService", "authToken", "$rootScope", "$route", "pageTitleService", "apiService", "$window", 'dropdownCategoryFilter', 'filterService',
    function ($scope, $location, authService, authToken, $rootScope, $route, pageTitleService, apiService, $window, dropdownCategoryFilter, filterService) {

      $scope.$route = $route; // for use in determining active tab (for CSS styling)

      $scope.pageTitleService = pageTitleService;

      $scope.checkIfOwnPage = function() {
        return _.contains(["/404", "/login", "/pages/signin"], $location.path());
      };

      $rootScope.isAuthenticated = authToken.isAuthenticated();

      // If user not authenticated (and user not already on login page) redirect to login
      if(!$rootScope.isAuthenticated && !_.contains(["/login"], $location.path())) {
        $window.location.href = "#/login";
      }

      // Delete JWT Auth token if unauthorized (401) response
      $scope.$on('STRING_REPRESENTS_AUTHORIZATION_REVOKED', function(event) {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken("Your MightySignal access has been revoked. Please contact us or your account admin for details.");
      });

      $scope.clickedNavLink = function(link) {
        mixpanel.track("Clicked Navigation Link", {
          link: link
        });
      }

      $scope.logUserOut = authToken.deleteToken;

      if($rootScope.isAuthenticated) {
        
        // Sets user permissions
        authService.permissions()
          .success(function(data) {
            $scope.canViewSupportDesk = data.can_view_support_desk;
            $scope.canViewAdSpend = data.can_view_ad_spend;
            $scope.canViewSdks = data.can_view_sdks;
            $scope.canViewStorewideSdks = data.can_view_storewide_sdks;
            $scope.canViewAdAttribution = data.can_view_ad_attribution;
            $rootScope.isAdmin = data.is_admin;
            $rootScope.isAdminAccount = data.is_admin_account;
            $rootScope.connectedOauth = data.connected_oauth;

            if (!$rootScope.connectedOauth) {
              $window.location.href = "#/login?token=" + authToken.get();
            }
          })
          .error(function() {
            $scope.canViewSupportDesk = false;
            $scope.canViewAdSpend = true;
            $scope.canViewSdks = false;
            $rootScope.isAdmin = false;
            $rootScope.isAdminAccount = false;
            $rootScope.connectedOauth = true;
          });


        var routeParams = $location.search();
        if (routeParams.platform) {
          APP_PLATFORM = JSON.parse(routeParams.platform).appPlatform
        }

        /* Populates "Categories" dropdown with list of categories */
        apiService.getCategories().success(function(data) {
          $rootScope.categoryFilterOptions = dropdownCategoryFilter(data);
        });

      }

      // For dashboard filter warning
      apiService.getScannedSdkNum().success(function(data) {
        $rootScope.scannedAndroidSdkNum = data.scannedAndroidSdkNum;
        $rootScope.scannedIosSdkNum = data.scannedIosSdkNum;
      });
  }])
  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope", "filterService",
    function($scope, apiService, $http, $rootScope, filterService) {

      $scope.mixpanelAnalyticsEventTooltip = function(name) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Methodology Modal Viewed",
          { "tooltipName": name }
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      if(!$rootScope.tags) $rootScope.tags = [];

      $scope.selectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('categories', item.label, 'Category', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('categories', item.id)
        },
        onDeselectAll: function() {
          filterService.removeFilter('categories')
        }
      };

      $scope.onFilterChange = function(parameter, value, displayName, limitToOneFilter) {
        if(parameter == 'downloads') {
          var customName = "";
          switch (value) {
            case '0':
              customName = "0 - 50K";
              break;
            case '1':
              customName = "50K - 500K";
              break;
            case '2':
              customName = "500K - 10M";
              break;
            case '3':
              customName = "10M - 100M";
              break;
            case '4':
              customName = "100M - 1B";
              break;
            case '5':
              customName = "1B - 5B";
              break;
          }
          value = {
            id: parseInt(value, 10),
            name: customName
          };
          filterService.addFilter(parameter, value, displayName, limitToOneFilter, customName);
        } else {
          filterService.addFilter(parameter, value, displayName, limitToOneFilter);
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
          listApiService.listAddNotify(type);
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
