import angular from 'angular';

import 'services/admin.service';
import 'utils/admin.utils';

import './components/ad-manager/ad-manager';
import './components/api-token/api-token';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .controller('AdminController', AdminController);

AdminController.$inject = [
  'adminService',
  '$auth',
  'authToken',
  '$stateParams',
  'pageTitleService',
  'adminUtils',
  'csvUtils',
  '$uibModal',
  'sdkLiveScanService',
];

function AdminController(
  adminService,
  $auth,
  authToken,
  $stateParams,
  pageTitleService,
  adminUtils,
  csvUtils,
  $uibModal,
  sdkLiveScanService,
) {
  const admin = this;

  admin.accountModel = {};
  admin.accounts = [];
  admin.accountFetchComplete = false;
  admin.sdkPlatform = 'ios';
  admin.sdkFollowers = [];
  admin.sdks = [];
  admin.userModel = {};

  admin.authenticate = authenticate;
  admin.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
  admin.checkedSdkFollower = checkedSdkFollower;
  admin.createAccount = createAccount;
  admin.createUser = createUser;
  admin.exportToCsv = exportToCsv;
  admin.followSdks = followSdks;
  admin.lastUsedClass = adminUtils.lastUsedClass;
  admin.loadUsers = loadUsers;
  admin.openAdIntelModal = openAdIntelModal;
  admin.openTokenModal = openTokenModal;
  admin.range = adminUtils.range;
  admin.removeSdk = removeSdk;
  admin.resendInvite = resendInvite;
  admin.sdkAutocompleteUrl = sdkAutocompleteUrl;
  admin.selectedSdk = selectedSdk;
  admin.settingChanged = settingChanged;
  admin.unlinkAccounts = unlinkAccounts;

  activate();

  function activate() {
    admin.id = $stateParams.id;
    getAccounts(admin.id);
    pageTitleService.setTitle('MightySignal - Admin');
  }

  function authenticate (provider, account) {
    $auth.authenticate(provider, { token: authToken.get() })
      .then(() => {
        account.salesforce_connected = true;
      })
      .catch((response) => {
        account.salesforce_connected = false;
        alert(response.data.error);
      });
  }

  function checkedSdkFollower (follower) {
    const index = admin.sdkFollowers.indexOf(follower);
    if (index > -1) {
      admin.sdkFollowers.splice(index, 1);
    } else {
      admin.sdkFollowers.push(follower);
    }
  }

  function createAccount (account, form) {
    adminService.createAccount(account.name)
      .then((data) => {
        admin.accounts.push(data.account);
        form.$setPristine();
        admin.account = {};
      }).catch((data) => {
        alert(data.errors);
      });
  }

  function createUser (user, account, form) {
    adminService.createUser(user.email, account.id)
      .then((data) => {
        account.users.push(data.user);
        form.$setPristine();
        admin.user = {};
        alert(`We have sent ${user.email} an email with instructions for getting set up`);
        adminService.trackUserCreate(account, user);
      });
  }

  function exportToCsv () {
    adminService.getCsv()
      .then((data) => {
        csvUtils.downloadCsv(data, 'mightysignal_sdk_report');
      });
  }

  function followSdks () {
    const userIds = [];
    const accountIds = [];

    for (let i = 0; i < admin.sdkFollowers.length; i++) {
      const follower = admin.sdkFollowers[i];
      if (follower.type === 'User') {
        userIds.push(follower.id);
      } else if (follower.type === 'Account') {
        accountIds.push(follower.id);
      }
    }

    adminService.followSdks(userIds, admin.sdks, accountIds)
      .then(() => {
        admin.sdks = [];
        admin.sdkFollowers = [];
        alert('Done!');
      });
  }

  function getAccounts () {
    const id = $stateParams.id;
    adminService.getAccounts(id)
      .then((data) => {
        admin.accounts = data.accounts;
        admin.accounts.forEach(account => account.isCollapsed = true);
        admin.accountFetchComplete = true;

        if (admin.accounts.length === 1) {
          admin.accounts[0].isCollapsed = false;
          loadUsers(0);
        }
      });
  }

  function loadUsers (index) {
    const account = admin.accounts[index];
    account.isLoading = true;
    adminService.getUsers(account.id)
      .then((data) => {
        account.users = data.users;
        account.following = data.following;
        account.isLoading = false;
      });
  }

  function openAdIntelModal (id) {
    $uibModal.open({
      animation: true,
      template: require('./components/ad-manager/ad-manager.html'),
      controller: 'adManagerController',
      controllerAs: 'adManager',
      size: 'lg',
      resolve: {
        id () {
          return id;
        },
      },
    });
  }

  function openTokenModal (id) {
    $uibModal.open({
      animation: true,
      ariaLabelledBy: 'apiTokenModalTitle',
      ariaDescribedBy: 'apiTokenModalBody',
      template: require('./components/api-token/api-token.html'),
      controller: 'apiTokenInstanceCtrl',
      controllerAs: '$ctrl',
      size: 'lg',
      resolve: {
        id () {
          return id;
        },
      },
    });
  }

  function removeSdk (index) {
    admin.sdks.splice(index, 1);
  }

  function resendInvite (user) {
    adminService.resendInvite(user.id);
  }

  function sdkAutocompleteUrl () {
    return `${API_URI_BASE}api/sdk/autocomplete?platform=${admin.sdkPlatform}&query=`;
  }

  function selectedSdk ($item) {
    const index = admin.sdks.indexOf($item.originalObject);
    if (index < 0) {
      admin.sdks.push($item.originalObject);
    }
  }

  function settingChanged (field, item) {
    const data = { id: item.id, field, type: item.type };

    if (field === 'seats_count') {
      data.value = item.seats_count;
    }

    adminService.updateSettings(data)
      .then((response) => {
        item = response.data.account;
      });
  }

  function unlinkAccounts ($accountIndex, $userIndex) {
    const user = admin.accounts[$accountIndex].users[$userIndex];
    adminService.unlinkAccounts(user.id)
      .then((response) => {
        alert('Done!');
        admin.accounts[$accountIndex].users[$userIndex] = response.data.user;
      })
      .catch((error) => {
        alert(error);
      });
  }
}
