'use strict';

angular.module('appApp').controller("AdminCtrl", ["$scope", "$rootScope", 'slacktivity', "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService',
  function($scope, $rootScope, slacktivity, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService) {

    $scope.initialPageLoadComplete = false;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.user = {};
    $scope.account = {};
    $scope.sdks = [];
    $scope.sdkUsers = [];

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
        $scope.accounts = data.accounts;
        for (var i = 0; i < $scope.accounts.length; i++) {
          $scope.accounts[i].isCollapsed = true;
        }
        $scope.initialPageLoadComplete = true;
        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Admin');
      });
    };
    
    $scope.load();

    $scope.loadUsers = function(account) {
      account.isLoading = true;
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/admin/account_users',
        params: {account_id: account.id}
      }).success(function(data) {
        account.users = data.users
        account.isLoading = false;
      });
    }

    $scope.sdkAutocompleteUrl = function() {
      return API_URI_BASE + "api/sdk/autocomplete?platform=ios&query="
    }

    $scope.checkedSdkUser = function(user) {
      var index = $scope.sdkUsers.indexOf(user)
      if (index > -1) {
        $scope.sdkUsers.splice(index, 1)
      } else {
        $scope.sdkUsers.push(user)
      }
    }

    $scope.selectedSdk = function ($item) {  
      var index = $scope.sdks.indexOf($item.originalObject)
      if (index < 0) {
        $scope.sdks.push($item.originalObject)
      }
    }

    $scope.followSDKs = function() {
      var user_ids = $scope.sdkUsers.map(function (user) {
        return user.id
      })
      var sdk_ids = $scope.sdks.map(function (sdk) {
        return sdk.id
      })
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/follow_sdks',
        data: {user_ids: user_ids, sdk_ids: sdk_ids}
      }).success(function(data) { 
        $scope.sdks = []
        $scope.sdkUsers = []
        alert("Done!")
      }).error(function(data) {
        alert(data.errors)
      })
    }

    $scope.removeSdk = function(index) {
      $scope.sdks.splice(index, 1)
    }

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
        
        mixpanel.track("New User Invited", {
          account: account.name,
          email: user.email,
          numUsers: account.users.length
        });
        var slacktivityData = {
          "title": "New User Invited",
          "fallback": "New User Invited",
          "color": "#FFD94D", // yellow
          "email": user.email,
          "account": account.name,
          "numUsers": account.users.length,
          "channel": '#new-users'
        };
        slacktivity.notifySlack(slacktivityData);
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

    $scope.lastUsedClass =  function(last_used) {
      var days = moment(moment()).diff(last_used, 'days')
      if(days <= 7) {
        return 'green';
      } else if(7 < days && days <= 14) {
        return 'yellow'
      } else if(14 < days && days <= 30) {
        return 'orange';
      } else {
        return 'red';
      }
    }

    $scope.exportToCsv = function() {
      $http({
        method: 'GET',
        url: API_URI_BASE + 'api/admin/export_to_csv'
      }).success(function(data) {
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:attachment/csv,' + encodeURI(data);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'mightysignal_sdk_report.csv';
        hiddenElement.click();
      })
    }

    mixpanel.track("Admin Viewed");
  }
]);
