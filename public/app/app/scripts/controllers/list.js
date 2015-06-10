'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "$routeParams", "$rootScope", "listApiService", function($scope, $http, $routeParams, $rootScope, listApiService) {

  listApiService.getLists().success(function(data) {
    $scope.usersLists = data;
    $rootScope.currentList = data[0].id;
  });

  $scope.createList = function(listName) {
    listApiService.createNewList(listName).success(function() {
      listApiService.getLists().success(function(data) {
        $scope.usersLists = data;
        $rootScope.currentList = data[0];
        location.reload();
      });
    });
  };
  $scope.getList = function(listId) {
    listApiService.getList(listId).success(function(data) {
      $rootScope.apps = data.results;
      $rootScope.numApps = data.resultsCount;
      $rootScope.currentList = data.currentList;
    });
  };
  $scope.addSelectedTo = function(list, selectedApps) {
    listApiService.addSelectedTo(list, selectedApps);
    $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
  };
  $scope.deleteSelected = function(listId, selectedApps) {
    listApiService.deleteSelected(listId, selectedApps).success(function() {
      $rootScope.selectedAppsForList = [];
      $scope.$apply()
    });

  };
  $scope.deleteList = function(listId) {
    listApiService.deleteList(listId).success(function() {
      location.reload();
    });
  };
  $scope.exportListToCsv = function(listId) {
    listApiService.exportToCsv(listId).success(function (content) {
        var hiddenElement = document.createElement('a');

        hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'mightysignal_list.csv';
        hiddenElement.click();
      });
  };
}]);
