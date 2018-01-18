import angular from 'angular';

angular.module('appApp')
  .controller('TableCtrl', ['$scope', 'apiService', 'listApiService', '$filter', '$rootScope', 'loggitService', 'AppPlatform',
    function ($scope, apiService, listApiService, $filter, $rootScope, loggitService, AppPlatform) {
      $rootScope.apps = [];
      $scope.searchKeywords = '';
      $scope.filteredApps = [];
      $scope.row = '';
      $scope.appPlatform = AppPlatform;
      $scope.appsDisplayedCount = function () {
        const lastPageMaxApps = $rootScope.numPerPage * $rootScope.currentPage;
        const baseAppNum = $rootScope.numPerPage * ($rootScope.currentPage - 1) + 1;
        if (lastPageMaxApps > $rootScope.numApps) {
          return `${baseAppNum} - ${$rootScope.numApps}`;
        }
        return `${baseAppNum} - ${lastPageMaxApps}`;
      };
      listApiService.getLists().success((data) => {
        $rootScope.usersLists = data;
      });
      $rootScope.selectedAppsForList = [];
      $scope.addSelectedTo = function (list, selectedApps) {
        listApiService.addSelectedTo(list, selectedApps).success(() => {
          $scope.notify('add-selected-success');
          $rootScope.selectedAppsForList = [];
        }).error(() => {
          $scope.notify('add-selected-error');
        });
        $rootScope.addSelectedToDropdown = ''; // Resets HTML select on view to default option
      };
      $scope.notify = function (type) {
        listApiService.listAddNotify(type);
      };
      $scope.onFilterChange = function () {
        $scope.select(1);
        $rootScope.currentPage = 1;
        $scope.row = '';
      };
      $scope.onNumPerPageChange = function () {
        $scope.select(1);
        $rootScope.currentPage = 1;
      };
      $scope.onOrderChange = function () {
        $scope.select(1);
        $rootScope.currentPage = 1;
      };
      $scope.search = function () {
        $scope.filteredApps = $filter('filter')($scope.apps, $scope.searchKeywords);
        $scope.onFilterChange();
      };
      $scope.numPerPageOpt = [100, 200, 350, 1000];
      $rootScope.numPerPage = $scope.numPerPageOpt[0];
      $rootScope.currentPage = 1;
      $scope.currentPageApps = [];
    },
  ]);
