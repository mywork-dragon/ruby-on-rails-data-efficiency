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
      $scope.submitSearch = function(tags) {

        var requestData = {app:{}, company:{}};

        tags.forEach(function(tag) {
          switch(tag.parameter) {
            case 'mobilePriority':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'adSpend':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'userBases':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'updatedDaysAgo':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'categories':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'fortuneRank':
              requestData['company'][tag.parameter] = tag.value;
              break;
            case 'customKeywords':
              requestData[tag.parameter] = [tag.value];
              break;
          }

        });

        return $http({
          method: 'POST',
          url: 'http://mightysignal.com/api/filter_ios_apps',
          data: requestData
        }).success(function(data) {
          console.log(data);
          $rootScope.apps = data;
        });
      };
      $scope.tags = [];
      $scope.onFilterChange = function(parameter, value, displayName) {
        console.log(parameter + value);
        $scope.tags.push({
          parameter: parameter,
          value: value,
          text: displayName + ': ' + value
        });
      }
    }
  ])
  .controller("TableCtrl", ["$scope", "$filter", "$rootScope",
    function($scope, $filter, $rootScope) {
      var init;
      return $rootScope.apps = [],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.select = function(page) {
          var end, start;
          return start = (page - 1) * $rootScope.numPerPage, end = start + $rootScope.numPerPage, $scope.apps = $scope.filteredApps.slice(start, end);
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
        $scope.order = function(rowName) {
          return $scope.row !== rowName ? ($scope.row = rowName, $scope.filteredApps = $filter("orderBy")($rootScope.apps, rowName), $scope.onOrderChange()) : void 0;
        },
        $scope.numPerPageOpt = [10, 50, 100, 200], $rootScope.numPerPage = $scope.numPerPageOpt[1], $rootScope.currentPage = 1, $scope.currentPageApps = [], (init = function() {
        return $scope.search(), $scope.select($rootScope.currentPage);
      }), $scope.search();
    }
  ]);


