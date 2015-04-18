'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", function ($scope, $location) {
    $scope.checkIfOwnPage = function() {

      return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

    };
  }])

  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope",
    function($scope, apiService, $http, $rootScope) {
      $scope.submitSearch = function() {
        $rootScope.dashboardSearchButtonDisabled = "true";
        apiService.searchRequestPost($rootScope.tags)
          .success(function(data) {
            console.log(data);
            $rootScope.apps = data.results;
            $rootScope.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = "false";
          });
      };
      $rootScope.tags = [];
      $scope.onFilterChange = function(parameter, value, displayName) {
        console.log(parameter + value);
        $rootScope.tags.push({
          parameter: parameter,
          value: value,
          text: displayName + ': ' + value
        });
      }
    }
  ])
  .controller("TableCtrl", ["$scope", "apiService", "$filter", "$rootScope",
    function($scope, apiService, $filter, $rootScope) {
      var init;
      return $rootScope.apps = [],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.select = function(page, tags) {

          var pageDetails = {page: page, numPerPage: $rootScope.numPerPage};

          apiService.searchRequestPost($rootScope.tags, pageDetails)
            .success(function(data) {
              console.log(data);
              $rootScope.apps = data.results;
              $rootScope.numApps = data.resultsCount;
              $rootScope.dashboardSearchButtonDisabled = "false";
            });

          var end, start;
          return start = (page - 1) * $rootScope.numPerPage, end = start + $rootScope.numPerPage;
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
        $scope.numPerPageOpt = [20, 50, 100, 200], $rootScope.numPerPage = $scope.numPerPageOpt[1], $rootScope.currentPage = 1, $scope.currentPageApps = [], (init = function() {
        return $scope.search(), $scope.select($rootScope.currentPage);
      }), $scope.search();
    }
  ]);


