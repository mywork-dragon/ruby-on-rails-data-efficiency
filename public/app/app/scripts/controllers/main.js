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
        return $http({
          method: 'POST',
          headers: {
            'Content-Type': 'json'
          },
          url: 'http://mightysignal.com/api/filter_ios_apps',
          data: {app: {adSpend: true}}
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
      return $rootScope.apps = [
        {
          id: 39849301,
          name: "TEST APP",
          countriesDeployed: [
            "US",
            "UK",
            "IN"
          ],
          mobilePriority: "Low",
          userBases: [
            "Elite",
            "Strong"
          ],
          lastUpdated: "2015-03-21",
          adSpend: true,
          company: {
            id: 123456789,
            name: "Coffee, Inc.",
            fortuneRank: 234,
            funding: 12000000,
            location: {
              streetAddress: "123 Main St.",
              city: "Gig Harbor",
              zipCode: "98333",
              state: "",
              country: "US"
            }
          }
        }, {
          id: 19849301,
          name: "APP",
          countriesDeployed: [
            "US",
            "UK",
            "IN"
          ],
          mobilePriority: "High",
          userBases: [
            "Elite",
            "Strong"
          ],
          lastUpdated: "2014-03-30",
          adSpend: true,
          company: {
            id: 123456789,
            name: "Piacitelli, Inc.",
            fortuneRank: 98,
            funding: 5670000,
            location: {
              streetAddress: "123 Main St.",
              city: "Gig Harbor",
              zipCode: "98333",
              state: "",
              country: "IN"
            }
          }
        }, {
          id: 29849301,
          name: "Patrick's App",
          countriesDeployed: [
            "US",
            "UK",
            "IN"
          ],
          mobilePriority: "High",
          userBases: [
            "Elite",
            "Strong"
          ],
          lastUpdated: "2015-03-30",
          adSpend: false,
          company: {
            id: 123456789,
            name: "Corporation, Inc.",
            fortuneRank: 498,
            funding: 3450000,
            location: {
              streetAddress: "123 Main St.",
              city: "Gig Harbor",
              zipCode: "98333",
              state: "",
              country: "CA"
            }
          }
        }],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.select = function(page) {
          var end, start;
          return start = (page - 1) * $scope.numPerPage, end = start + $scope.numPerPage, $scope.apps = $scope.filteredApps.slice(start, end);
        },
        $scope.onFilterChange = function() {
          return $scope.select(1), $scope.currentPage = 1, $scope.row = "";
        },
        $scope.onNumPerPageChange = function() {
          return $scope.select(1), $scope.currentPage = 1;
        },
        $scope.onOrderChange = function() {
          return $scope.select(1), $scope.currentPage = 1;
        },
        $scope.search = function() {
          return $scope.filteredApps = $filter("filter")($scope.apps, $scope.searchKeywords), $scope.onFilterChange();
        },
        $scope.order = function(rowName) {
          return $scope.row !== rowName ? ($scope.row = rowName, $scope.filteredApps = $filter("orderBy")($scope.apps, rowName), $scope.onOrderChange()) : void 0;
        },
        $scope.numPerPageOpt = [10, 50, 100, 200], $scope.numPerPage = $scope.numPerPageOpt[0], $scope.currentPage = 1, $scope.currentPageApps = [], (init = function() {
          return $scope.search(), $scope.select($scope.currentPage);
        }), $scope.search();
    }
  ]);


