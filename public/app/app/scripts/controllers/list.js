'use strict';

angular.module('appApp').controller("ListCtrl", ["$scope", "$http", "authToken", "$stateParams", "$rootScope", "listApiService", "searchService", "pageTitleService", "$state", "authService", "$location",
  function($scope, $http, authToken, $stateParams, $rootScope, listApiService, searchService, pageTitleService, $state, authService, $location) {
    $scope.AllSelectedItems = false;
    $scope.NoSelectedItems = false;

    if ($location.url().includes('custom')) {
      pageTitleService.setTitle("MightySignal - Search")
    }

    $scope.load = function() {
      $scope.queryInProgress = true;
      listApiService.getList($stateParams.id).success(function(data) {
        $scope.queryInProgress = false;
        $rootScope.apps = data.results;
        $rootScope.numApps = data.resultsCount;
        $rootScope.currentList = $stateParams.id;
      }).error(function() {
        $scope.queryInProgress = false;
      });
    };

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
      listApiService.deleteSelected($stateParams.id, selectedApps).success(function() {
        $rootScope.selectedAppsForList = [];
        $scope.load();
      });
    };

    $scope.deleteList = function() {
      listApiService.deleteList($stateParams.id).success(function() {
        listApiService.getLists().success(function(data) {
          $rootScope.usersLists = data;
          $state.go('timeline')
          $(".modal-backdrop").remove();
        });
      });
    };

    $scope.exportListToCsv = function() {
      listApiService.exportToCsv($stateParams.id)
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
      pageTitleService.setTitle(`MightySignal - ${listName}`);

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

    if ($rootScope.isAuthenticated) {
      authService.userInfo().success(function(data) {
        mixpanel.identify(data.email);
        mixpanel.people.set({
          "$email": data.email,
          "jwtToken": authToken.get()
        });
      });

      // Sets user permissions
      authService.permissions()
      .success(function(data) {
          $scope.canViewExports = data.can_view_exports;
      });

      listApiService.getLists().success(function(data) {
        $rootScope.usersLists = data;
      });

      $scope.load();
    }

}]);
