'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "authService", "authToken", "listApiService", "$rootScope", "$route", function ($scope, $location, authService, authToken, listApiService, $rootScope, $route) {

    $scope.$route = $route; // for use in determining active tab (for CSS styling)

    $scope.checkIfOwnPage = function() {

      return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

    };

    $scope.isAuthenticated = authToken.isAuthenticated();

    /* Login specific logic */
    $scope.onLoginButtonClick = function() {

      authService.login($scope.userEmail, $scope.userPassword).then(function(){
        $scope.isAuthenticated = authToken.isAuthenticated();
        listApiService.getLists().success(function(data) {
          $scope.usersLists = data;
        });
          location.reload();
      },
      function(){
        alert('Incorrect Email or Password');
      });
    };

    $scope.logUserOut = authToken.deleteToken;

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

      // When main Dashboard search button is clicked
      $scope.submitSearch = function() {

        var submitSearchStartTime = new Date().getTime();

        $rootScope.dashboardSearchButtonDisabled = true;
        apiService.searchRequestPost($rootScope.tags)
          .success(function(data) {
            $rootScope.apps = data.results;
            $rootScope.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            $rootScope.currentPage = 1;
            $rootScope.resultsSortCategory = 'appName';
            $rootScope.resultsOrderBy = 'ASC';

            var submitSearchEndTime = new Date().getTime();

            var submitSearchElapsedTime = submitSearchEndTime - submitSearchStartTime;

            /* -------- Mixpanel Analytics Start -------- */
            var searchQueryPairs = {};
            var searchQueryFields = [];
            $rootScope.tags.forEach(function(tag) {
              searchQueryPairs[tag.parameter] = tag.value;
              searchQueryFields.push(tag.parameter);
            });
            searchQueryPairs['tags'] = searchQueryFields;
            searchQueryPairs['numOfApps'] = data.resultsCount;
            searchQueryPairs['elapsedTimeInMS'] = submitSearchElapsedTime;
            searchQueryPairs['platform']  = APP_PLATFORM;

            mixpanel.track(
              "Search Request Successful",
              searchQueryPairs
            );
            /* -------- Mixpanel Analytics End -------- */

          })
          .error(function(data, status) {
            $rootScope.dashboardSearchButtonDisabled = false;
            mixpanel.track(
              "Search Request Failed",
              {
                "tags": $rootScope.tags,
                "errorMessage": data,
                "errorStatus": status,
                "platform": APP_PLATFORM
              }
            );
          });
      };
      $rootScope.tags = [];
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
  .controller("TableCtrl", ["$scope", "apiService", "listApiService", "$filter", "$rootScope", "loggitService",
    function($scope, apiService, listApiService, $filter, $rootScope, loggitService) {
      var init;
      return $rootScope.apps = [],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.appPlatform = "ios",
        // When table's paging options are selected
        $scope.select = function(page, tags) {

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Table Page Changed", {
              "page": page,
              "tags": tags,
              "appPlatform": APP_PLATFORM
            }
          );
          /* -------- Mixpanel Analytics End -------- */

          apiService.searchRequestPost($rootScope.tags, page, $rootScope.numPerPage, $rootScope.resultsSortCategory, $rootScope.resultsOrderBy)
            .success(function(data) {
              $rootScope.apps = data.results;
              $rootScope.numApps = data.resultsCount;
              $rootScope.dashboardSearchButtonDisabled = false;
              $rootScope.currentPage = page;
            })
            .error(function() {
              $rootScope.dashboardSearchButtonDisabled = false;
            });

          var end, start;
          return start = (page - 1) * $rootScope.numPerPage, end = start + $rootScope.numPerPage;
        },
        $scope.changeAppPlatform = function(platform) {
          $scope.appPlatform = platform;
          APP_PLATFORM = platform;
          apiService.getCategories().success(function(data) {
            $rootScope.categoryFilterOptions = data;
          });
        },
        listApiService.getLists().success(function(data) {
          $scope.usersLists = data;
        }),
        $rootScope.selectedAppsForList = [],
        $scope.addSelectedTo = function(list, selectedApps) {
          listApiService.addSelectedTo(list, selectedApps, $scope.appPlatform).success(function() {
            $scope.notify('add-selected-success');
            $rootScope.selectedAppsForList = [];
            $scope.uncheckAllCheckboxes();
          }).error(function() {
            $scope.notify('add-selected-error');
          });
          $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
        },
        $scope.checkAllCheckboxes = function() {
          $scope.selectAppCheckbox = angular.copy($rootScope.apps);
        },
        $scope.uncheckAllCheckboxes = function() {
          $scope.selectAppCheckbox = [];
        },
        $scope.notify = function(type) {
          switch (type) {
            case "add-selected-success":
              return loggitService.logSuccess("Items were added successfully.");
            case "add-selected-error":
              return loggitService.logError("Error! Something went wrong while adding to list.");
          }
        },
        $scope.addAppToList = function(selectedApp) {
          listApiService.modifyCheckbox(selectedApp.id, selectedApp.type, $rootScope.selectedAppsForList);
        },
        // When orderby/sort arrows on dashboard table are clicked
        $scope.sortApps = function(category, order) {


          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Table Sorting Changed", {
              "category": category,
              "order": order,
              "appPlatform": APP_PLATFORM
            }
          );
          /* -------- Mixpanel Analytics End -------- */

          var firstPage = 1;
          apiService.searchRequestPost($rootScope.tags, firstPage, $rootScope.numPerPage, category, order)
            .success(function(data) {
              $rootScope.apps = data.results;
              $rootScope.numApps = data.resultsCount;
              $rootScope.dashboardSearchButtonDisabled = false;
              $rootScope.currentPage = 1;
              $rootScope.resultsSortCategory = category;
              $rootScope.resultsOrderBy = order;
            })
            .error(function() {
              $rootScope.dashboardSearchButtonDisabled = false;
            });
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
        $scope.numPerPageOpt = [20, 50, 100, 200],
        $rootScope.numPerPage = $scope.numPerPageOpt[1],
        $rootScope.currentPage = 1,
        $scope.currentPageApps = []
    }
  ]);
