import angular from 'angular';

angular.module('appApp')
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
        listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
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
])
