'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "$routeParams", "$rootScope", "listApiService", "pageTitleService",
  function($scope, $http, $routeParams, $rootScope, listApiService, pageTitleService) {

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "Page Viewed",
      { "pageType": "Lists",
        "userauthenticated": $scope.isAuthenticated,
        "listId": $routeParams.id }
    );
    /* -------- Mixpanel Analytics End -------- */

    /* Sets html title attribute */
    pageTitleService.setTitle("MightySignal");

    $scope.load = function() {
      $scope.queryInProgress = true;
      listApiService.getList($routeParams.id).success(function(data) {
        $scope.queryInProgress = false;
        $rootScope.apps = data.results;
        $rootScope.numApps = data.resultsCount;
        $rootScope.currentList = $routeParams.id;
      }).error(function() {
        $scope.queryInProgress = false;
      });
    };
    listApiService.getLists().success(function(data) {
      $rootScope.usersLists = data;
    });

    $scope.createList = function(listName) {
      listApiService.createNewList(listName).success(function() {
        listApiService.getLists().success(function(data) {
          $rootScope.usersLists = data;
          $('#createNewModal').hide();
          $('.modal-backdrop.fade.in').hide();
        });
      });
    };
    $scope.deleteSelected = function(selectedApps) {
      listApiService.deleteSelected($routeParams.id, selectedApps).success(function() {
        $rootScope.selectedAppsForList = [];
        $scope.load();
      });
    };
    $scope.deleteList = function() {
      listApiService.deleteList($routeParams.id).success(function() {
        listApiService.getLists().success(function(data) {
          $rootScope.usersLists = data;
        });
      });
    };
    $scope.exportListToCsv = function() {
      listApiService.exportToCsv($routeParams.id)
        .success(function (content) {
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
