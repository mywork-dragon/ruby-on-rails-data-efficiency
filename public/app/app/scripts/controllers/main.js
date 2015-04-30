'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "$rootScope", function ($scope, $location, $rootScope) {

    $scope.checkIfOwnPage = function() {

      return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

    };

    $rootScope.checkIfUserAuthenticated = function() {
      $scope.isAuthenticated = localStorage.getItem('custom_auth_token') != null;
    };

    $rootScope.checkIfUserAuthenticated();

  }])
  .controller('LoginCtrl', ['$scope', '$auth', '$rootScope', function($scope, $auth, $rootScope) {
    $scope.onLoginButtonClick = function() {
      $auth.submitLogin({email: $scope.user.email, password: $scope.user.password})
        .then(function(resp) {
          console.log('LOGIN SUCCESS!');
          localStorage.setItem('custom_auth_token', resp.email);
          mixpanel.identify(resp.email);

          mixpanel.people.set({
              "$email": resp.email
          });

          $rootScope.checkIfUserAuthenticated();
          location.reload();
        })
        .catch(function(resp) {
          console.log('LOGIN FAILED!');
        });

    };
  }])
  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope",
    function($scope, apiService, $http, $rootScope) {
      mixpanel.track(
        "Search Page Viewed",
        { "userauthenticated": $scope.isAuthenticated }
      );

      /* Initializes all Bootstrap tooltips */
      $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      })

      // When main Dashboard surch button is clicked
      $scope.submitSearch = function() {

        mixpanel.track(
          "Search Submitted",
          { "tags": $rootScope.tags }
        );

        $rootScope.dashboardSearchButtonDisabled = true;
        apiService.searchRequestPost($rootScope.tags)
          .success(function(data) {
            console.log(data);
            $rootScope.apps = data.results;
            $rootScope.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            $rootScope.currentPage = 1;
            $rootScope.resultsSortCategory = 'appName';
            $rootScope.resultsOrderBy = 'ASC';
          })
          .error(function() {
            $rootScope.dashboardSearchButtonDisabled = false;
          });
      };
      $rootScope.tags = [];
      $scope.onFilterChange = function(parameter, value, displayName, limitToOneFilter) {
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

          mixpanel.track(
            "Table Page Changed", {
              "page": page,
              "tags": tags
            }
          );

          apiService.searchRequestPost($rootScope.tags, page, $rootScope.numPerPage, $rootScope.resultsSortCategory, $rootScope.resultsOrderBy)
            .success(function(data) {
              console.log(data);
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
        };
        // When orderby/sort arrows on dashboard table are clicked
        $scope.sortApps = function(category, order) {
          var firstPage = 1;
          apiService.searchRequestPost($rootScope.tags, firstPage, $rootScope.numPerPage, category, order)
            .success(function(data) {
              console.log(data);
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
  ])
  .controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", function($scope, $http, $routeParams) {
    $scope.load = function() {

      return $http({
        method: 'POST',
        url: 'http://mightysignal.com/api/get_ios_app',
        // url: 'http://localhost:3000/api/get_ios_app',
        params: {id: $routeParams.id}
      }).success(function(data) {
        $scope.appData = data;
        console.log(data);
      });
    };

    $scope.load();

    mixpanel.track(
      "App Page Viewed", {
        "appid": $routeParams.id
        //"appname": $scope.appData.name  //was breaking
      }
    );
  }
  ])
  .controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", function($scope, $http, $routeParams) {
    $scope.load = function() {

      return $http({
        method: 'POST',
        url: 'http://mightysignal.com/api/get_company',
        // url: 'http://localhost:3000/api/get_company',
        params: {id: $routeParams.id}
      }).success(function(data) {
        $scope.companyData = data;
        console.log(data);
      });
    };

    $scope.load();

    mixpanel.track(
      "Company Page Viewed", {
        "companyid": $routeParams.id
        //"companyname": $scope.companyData.name  //was breaking
      }
    );
  }
  ]);
