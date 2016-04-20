'use strict';

angular.module('appApp').controller("AdminCtrl", ["$scope", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService',
  function($scope, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService) {

    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = $scope.isAdminAccount;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.user = {};
    $scope.account = {};

    $scope.range = function(n) {
      var arr = []
      for (var i = 1; i <= n; i++) {
        arr.push(i)
      }
      return arr;
    };

    $scope.load = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/admin',
        params: {page: $scope.page}
      }).success(function(data) {
        $scope.accounts = data.accounts
        $scope.initialPageLoadComplete = true;
        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Admin');
      });
    };
    
    $scope.load();

    $scope.settingChanged = function(field, item) {
      var data = {id: item.id, field: field, type: item.type}

      if (field === 'seats_count') {
        data.value = item.seats_count 
      }

      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/update',
        data: data
      }).success(function(data) { 
        item = data.account
      });
    }

    $scope.createUser = function(user, account, form) {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/create_user',
        data: {email: user.email, account_id: account.id}
      }).success(function(data) { 
        account.users.push(data.user)
        form.$setPristine()
        $scope.user = {};
        alert("We have sent " + user.email + " an email with instructions for getting set up")
      }).error(function(data) {
        alert(data.errors)
      })
    }

    $scope.createAccount = function(account, form) {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/create_account',
        data: {name: account.name}
      }).success(function(data) { 
        $scope.accounts.push(data.account)
        form.$setPristine()
        $scope.account = {}
      }).error(function(data) {
        alert(data.errors)
      })
    }

    mixpanel.track("Admin Viewed");
  }
]);
