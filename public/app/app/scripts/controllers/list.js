'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "$routeParams", "$rootScope", "listApiService", "searchService", "pageTitleService", "$window", "authService",
  function($scope, $http, $routeParams, $rootScope, listApiService, searchService, pageTitleService, $window, authService) {

    /* Sets html title attribute */
    pageTitleService.setTitle("MightySignal");

    // Sets user permissions
    authService.permissions()
      .success(function(data) {
        $scope.canViewExports = data.can_view_exports;
      });

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
          $window.location.href = "#/timeline";
          $(".modal-backdrop").remove();
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
    $scope.getLastUpdatedDaysClass = function(lastUpdatedDays) {
      return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
    };
    $scope.recordListViewEvent = function(listName, listId) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "List Viewed",
        { "pageType": "Lists",
          "userauthenticated": $rootScope.isAuthenticated,
          "listId": listId,
          "listName": listName }
      );
      /* -------- Mixpanel Analytics End -------- */
    };
    $scope.AllSelectedItems = false;
    $scope.NoSelectedItems = false;

    $scope.load();

}]);
