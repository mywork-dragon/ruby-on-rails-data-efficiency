'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "$routeParams", "$rootScope", "listApiService", "$location",
  function($scope, $http, $routeParams, $rootScope, listApiService, $location) {

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "Page Viewed",
      { "pageType": "Lists",
        "userauthenticated": $scope.isAuthenticated,
        "listId": $routeParams.id }
    );
    /* -------- Mixpanel Analytics End -------- */

    $scope.load = function() {
      listApiService.getList($routeParams.id).success(function(data) {
        $rootScope.apps = data.results;
        $rootScope.numApps = data.resultsCount;
        $rootScope.currentList = $routeParams.id;
      });
    };
    listApiService.getLists().success(function(data) {
      $scope.usersLists = data;
    });

    $scope.createList = function(listName) {
      listApiService.createNewList(listName).success(function() {
        listApiService.getLists().success(function(data) {
          $scope.usersLists = data;
          location.reload();
        });
      });
    };
    $scope.getList = function() {

    };
    $scope.addSelectedTo = function(list, selectedApps) {
      listApiService.addSelectedTo(list, selectedApps);
      $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };
    $scope.deleteSelected = function(selectedApps) {
      listApiService.deleteSelected($routeParams.id, selectedApps).success(function() {
        $rootScope.selectedAppsForList = [];
        location.reload();
      });
    };
    $scope.deleteList = function() {
      listApiService.deleteList($routeParams.id).success(function() {
        location.reload();
      });
    };
    $scope.exportListToCsv = function() {
      listApiService.exportToCsv($routeParams.id).success(function (content) {
          var hiddenElement = document.createElement('a');

          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'mightysignal_list.csv';
          hiddenElement.click();
        });

    };
    $scope.updateCheckboxStatus = function(appId, appType) {
      $rootScope.selectedAppsForList.forEach(function(app) {
        if(app.id == appId && app.type == appType) {
          return true;
        }
      });
      return false;
    };
    $scope.AllSelectedItems = false;
    $scope.NoSelectedItems = false;

    $scope.load();

}]);
