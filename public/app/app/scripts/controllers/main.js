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

  .controller("FilterCtrl", ["$scope",
    function($scope) {
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
  .controller("TableCtrl", ["$scope", "$filter", "apiService",
    function($scope, $filter, apiService) {
      var init;
      return $scope.apps = [
        {
          id: 19849301,
          name: apiService.postDashboardSearch("TEST APP"),
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
          lastUpdated: "Nov 3, 2014",
          adSpend: true,
          company: {
            id: 123456789,
            name: "Corporation, Inc.",
            fortuneRank: 234,
            funding: 5670000,
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
          name: apiService.postDashboardSearch("TEST APP"),
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
          lastUpdated: "Nov 3, 2014",
          adSpend: true,
          company: {
            id: 123456789,
            name: "Corporation, Inc.",
            fortuneRank: 234,
            funding: 5670000,
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
          name: apiService.postDashboardSearch("TEST APP"),
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
          lastUpdated: "Nov 3, 2014",
          adSpend: true,
          company: {
            id: 123456789,
            name: "Corporation, Inc.",
            fortuneRank: 234,
            funding: 5670000,
            location: {
              streetAddress: "123 Main St.",
              city: "Gig Harbor",
              zipCode: "98333",
              state: "",
              country: "US"
            }
          }
        }], $scope.searchKeywords = "", $scope.filteredApps = [], $scope.row = "", $scope.select = function(page) {
        var end, start;
        return start = (page - 1) * $scope.numPerPage, end = start + $scope.numPerPage, $scope.apps = $scope.filteredApps.slice(start, end);
      }, $scope.onFilterChange = function() {
        return $scope.select(1), $scope.currentPage = 1, $scope.row = "";
      }, $scope.onNumPerPageChange = function() {
        return $scope.select(1), $scope.currentPage = 1;
      }, $scope.onOrderChange = function() {
        return $scope.select(1), $scope.currentPage = 1;
      }, $scope.search = function() {
        return $scope.filteredApps = $filter("filter")($scope.apps, $scope.searchKeywords), $scope.onFilterChange();
      }, $scope.order = function(rowName) {
        return $scope.row !== rowName ? ($scope.row = rowName, $scope.filteredApps = $filter("orderBy")($scope.apps, rowName), $scope.onOrderChange()) : void 0;
      }, $scope.numPerPageOpt = [10, 50, 100, 200], $scope.numPerPage = $scope.numPerPageOpt[0], $scope.currentPage = 1, $scope.currentPageApps = [], (init = function() {
        return $scope.search(), $scope.select($scope.currentPage);
      }), $scope.search();
    }
  ]);


