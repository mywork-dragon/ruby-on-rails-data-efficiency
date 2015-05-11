'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "authService", "$auth", function ($scope, $location, authService, $auth) {

    $scope.checkIfOwnPage = function() {

      return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

    };

    $scope.isAuthenticated = authService.isAuthenticated();

    /* Login specific logic */
    $scope.onLoginButtonClick = function() {
      $auth.submitLogin({email: $scope.user.email, password: $scope.user.password})
        .then(function(resp) {
          localStorage.setItem('custom_auth_token', resp.email);

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.identify(resp.email);

          mixpanel.people.set({
              "$email": resp.email
          });

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Login Success"
          );
          /* -------- Mixpanel Analytics End -------- */

          $scope.isAuthenticated = authService.isAuthenticated();
          location.reload();
        })
        .catch(function(resp) {
        });

    };
  }])
  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope",
    function($scope, apiService, $http, $rootScope) {

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "Search Page Viewed",
        { "userauthenticated": $scope.isAuthenticated }
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

      // When main Dashboard surch button is clicked
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
                "errorStatus": status
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

        if(limitToOneFilter) {
          var tagUpdated = false;
          $rootScope.tags.forEach(function (tag) {
            // If replacing pre existing tag of limitToOneFilter = true category
            if (tag.parameter == parameter) {
              tag.value = value;
              tag.text = displayName + ': ' + value;
              tagUpdated = true;
            }
          });
          // If first tag of limitToOneFilter = true category
          if (!tagUpdated) {
            $rootScope.tags.push({
              parameter: parameter,
              value: value,
              text: displayName + ': ' + value
            });
          }
        // If first or pre existing tag of limitToOneFilter = false category
        } else {
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
  .controller("TableCtrl", ["$scope", "apiService", "$filter", "$rootScope",
    function($scope, apiService, $filter, $rootScope) {
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
              "tags": tags
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
        },
        // When orderby/sort arrows on dashboard table are clicked
        $scope.sortApps = function(category, order) {


          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Table Sorting Changed", {
              "category": category,
              "order": order
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
