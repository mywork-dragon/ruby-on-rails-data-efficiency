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
    $scope.tags = [
      'Mobile Priority: High',
      'Country: USA',
      'Reported Ad Spend: $1K - $10K'
    ];
    $scope.checkIfOwnPage = function() {

      return _.contains(["/404", "/pages/500", "/pages/login", "/pages/signin", "/pages/signin1", "/pages/signin2", "/pages/signup", "/pages/signup1", "/pages/signup2", "/pages/forgot", "/pages/lock-screen"], $location.path());

    };

    $scope.info = {
      theme_name: "MightySignal",
      user_name: "Jane Doe"
    };
    $scope.navInfo = {
      tasks_number: 5,
      widgets_number: 13
    };
  }])
  .controller("tableCtrl", ["$scope", "$filter",
    function($scope, $filter) {
      var init;
      return $scope.stores = [{
        name: "Instagram",
        company: "Instagram, Inc.",
        priority: 292,
        downloads: "332M",
        genre: "Social",
        lastUpdated: "March 25th, 2015",
        averageUpdate: "5 Days",
        companySize: "200 - 300",
        funding: "Acquired for $1B",
        adSpend: "$1K - $10K",
        country: "USA",
        details: "Details",
      }, {
        name: "Snapchat",
        company: "Snapchat, Inc.",
        priority: 200,
        downloads: "128M",
        genre: "Social",
        lastUpdated: "March 26th, 2015",
        averageUpdate: "8 Days",
        companySize: "200 - 300",
        funding: "Acquired for $1B",
        adSpend: "$1K - $10K",
        country: "USA",
        details: "Details",
      }, {
        name: "Netflix",
        company: "Netflix, Inc.",
        priority: 178,
        downloads: "106M",
        genre: "Entertainment",
        lastUpdated: "March 31st, 2015",
        averageUpdate: "13 Days",
        companySize: "1000 - 5000",
        funding: "Public",
        adSpend: "$100K - $1M",
        country: "USA",
        details: "Details",
      }, {
        name: "King of Thieves",
        company: "ZeptoLab",
        priority: 292,
        downloads: "332M",
        genre: "Game - Strategy",
        lastUpdated: "March 4th, 2015",
        averageUpdate: "23 Days",
        companySize: "10 - 50",
        funding: "$53M - B Round",
        adSpend: "$1K - $10K",
        country: "USA",
        details: "Details",
      }, {
        name: "Angry Birds",
        company: "Rovio Entertainment Ltd.",
        priority: 312,
        downloads: "221M",
        genre: "Game - Classic Arcade",
        lastUpdated: "December 11th, 2014",
        averageUpdate: "63 Days",
        companySize: "50 - 100",
        funding: "$73M - B Round",
        adSpend: "$10K - $100K",
        country: "USA",
        details: "Details",
      }, {
        name: "Netflix",
        company: "Netflix, Inc.",
        priority: 178,
        downloads: "106M",
        genre: "Entertainment",
        lastUpdated: "March 31st, 2015",
        averageUpdate: "13 Days",
        companySize: "1000 - 5000",
        funding: "Public",
        adSpend: "$100K - $1M",
        country: "USA",
        details: "Details",
      }, {
        name: "Instagram",
        company: "Instagram, Inc.",
        priority: 292,
        downloads: "332M",
        genre: "Social",
        lastUpdated: "March 25th, 2015",
        averageUpdate: "5 Days",
        companySize: "200 - 300",
        funding: "Acquired for $1B",
        adSpend: "$1K - $10K",
        country: "USA",
        details: "Details",
      }, {
        name: "Snapchat",
        company: "Snapchat, Inc.",
        priority: 200,
        downloads: "128M",
        genre: "Social",
        lastUpdated: "March 26th, 2015",
        averageUpdate: "8 Days",
        companySize: "200 - 300",
        funding: "Acquired for $1B",
        adSpend: "$1K - $10K",
        country: "USA",
        details: "Details",
      }], $scope.searchKeywords = "", $scope.filteredStores = [], $scope.row = "", $scope.select = function(page) {
        var end, start;
        return start = (page - 1) * $scope.numPerPage, end = start + $scope.numPerPage, $scope.currentPageStores = $scope.filteredStores.slice(start, end);
      }, $scope.onFilterChange = function() {
        return $scope.select(1), $scope.currentPage = 1, $scope.row = "";
      }, $scope.onNumPerPageChange = function() {
        return $scope.select(1), $scope.currentPage = 1;
      }, $scope.onOrderChange = function() {
        return $scope.select(1), $scope.currentPage = 1;
      }, $scope.search = function() {
        return $scope.filteredStores = $filter("filter")($scope.stores, $scope.searchKeywords), $scope.onFilterChange();
      }, $scope.order = function(rowName) {
        return $scope.row !== rowName ? ($scope.row = rowName, $scope.filteredStores = $filter("orderBy")($scope.stores, rowName), $scope.onOrderChange()) : void 0;
      }, $scope.numPerPageOpt = [10, 50, 100, 200], $scope.numPerPage = $scope.numPerPageOpt[0], $scope.currentPage = 1, $scope.currentPageStores = [],
        $scope.tags = [
          "foo",
          "bar"
        ], (init = function() {
        return $scope.search(), $scope.select($scope.currentPage);
      }), $scope.search();
    }
  ]);


