import angular from 'angular'
import mixpanel from 'mixpanel-browser'

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .service('adminService', adminService);

adminService.$inject = ['$http'];

function adminService($http) {
  return {
    createAccount,
    createUser,
    followSdks,
    getAccounts,
    getCsv,
    getUsers,
    resendInvite,
    trackUserCreate,
    unlinkAccounts,
    updateSettings
  }

  function createAccount (name) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/create_account',
      data: {name: name}
    })
    .then(response => response.data)
  }

  function createUser (email, accountId) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/create_user',
      data: {email, account_id: accountId}
    })
    .then(response => response.data)
  }

  function followSdks (userIds, sdks, accountIds) {
    debugger
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/follow_sdks',
      data: {user_ids: userIds, sdks, account_ids: accountIds}
    })
    .then(response => response.data)
  }

  function getAccounts (id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/admin',
      params: {account_id: id}
    })
    .then(response => response.data)
  }

  function getCsv () {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/admin/export_to_csv'
    })
    .then(response => response.data)
  }

  function getUsers (id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/admin/account_users',
      params: {account_id: id}
    })
    .then(response => response.data)
  }

  function resendInvite (id) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/resend_invite',
      data: {user_id: id}
    }).success(function(data) {
      alert("Done!")
    }).error(function(data) {
      alert(data.errors)
    })
  }

  function trackUserCreate (account, user) {
    mixpanel.track("New User Invited", {
      account: account.name,
      email: user.email,
      numUsers: account.users.length
    });
  }

  function unlinkAccounts (id) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/unlink_accounts',
      data: {user_id: id}
    })
  }

  function updateSettings (data) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/update',
      data
    })
  }
}
