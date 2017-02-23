'use strict';

angular.module('appApp').controller("AdminCtrl", ["$scope", "$rootScope", 'slacktivity', "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService',
  function($scope, $rootScope, slacktivity, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService) {

    var adminCtrl = this
    $scope.initialPageLoadComplete = false;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    $scope.user = {};
    $scope.account = {};
    $scope.sdks = [];
    $scope.sdkFollowers = [];
    adminCtrl.sdkPlatform = 'ios'

    $scope.range = function(n) {
      var arr = []
      for (var i = 1; i <= n; i++) {
        arr.push(i)
      }
      return arr;
    };

    $scope.resendInvite = function(user) {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/resend_invite',
        data: {user_id: user.id}
      }).success(function(data) { 
        alert("Done!")
      }).error(function(data) {
        alert(data.errors)
      })
    }

    $scope.unlinkAccounts = function($accountIndex, $userIndex) {
      var user = $scope.accounts[$accountIndex].users[$userIndex]
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/unlink_accounts',
        data: {user_id: user.id}
      }).success(function(data) { 
        alert("Done!")
        $scope.accounts[$accountIndex].users[$userIndex] = data.user
      }).error(function(data) {
        alert(data.errors)
      })
    }

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

    $scope.loadUsers = function($index) {
      var account = $scope.accounts[$index]
      account.isLoading = true;
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/admin/account_users',
        params: {account_id: account.id}
      }).success(function(data) {
        account.users = data.users
        account.following = data.following
        account.isLoading = false;
      });
    }

    $scope.sdkAutocompleteUrl = function() {
      return API_URI_BASE + 'api/sdk/autocomplete?platform=' + adminCtrl.sdkPlatform + '&query='
    }

    $scope.checkedSdkFollower = function(follower) {
      var index = $scope.sdkFollowers.indexOf(follower)
      if (index > -1) {
        $scope.sdkFollowers.splice(index, 1)
      } else {
        $scope.sdkFollowers.push(follower)
      }
    }

    $scope.selectedSdk = function ($item) { 
      var index = $scope.sdks.indexOf($item.originalObject)
      if (index < 0) {
        $scope.sdks.push($item.originalObject)
      }
    }

    $scope.followSDKs = function() {
      var userIds = [];
      var accountIds = [];

      for (var i = 0; i < $scope.sdkFollowers.length; i++) {
        var follower = $scope.sdkFollowers[i];
        if (follower.type == 'User') {
          userIds.push(follower.id)
        } else if (follower.type == 'Account') {
          accountIds.push(follower.id)
        }
      }
      
      var sdkIds = $scope.sdks.map(function (sdk) {
        return sdk.id
      })

      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/admin/follow_sdks',
        data: {user_ids: userIds, sdks: $scope.sdks, account_ids: accountIds}
      }).success(function(data) { 
        $scope.sdks = []
        $scope.sdkFollowers = []
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
          "newUserEmail": user.email,
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
