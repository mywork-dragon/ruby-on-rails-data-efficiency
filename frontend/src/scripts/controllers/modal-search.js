import angular from 'angular';

angular.module('appApp')
  .controller('ModalSearchCtrl', ['$scope', 'customSearchService', '$state',
    function ($scope, customSearchService, $state) {
      const modalSearchCtrl = this;
      modalSearchCtrl.searchItem = 'app';
      modalSearchCtrl.results = null;

      /* For query load when /search/:query path hit */
      modalSearchCtrl.loadData = function () {
        modalSearchCtrl.queryInProgress = true;
        customSearchService.customSearch(modalSearchCtrl.searchItem, modalSearchCtrl.searchInput, 1, 10)
          .success((data) => {
            modalSearchCtrl.results = data[modalSearchCtrl.appsKey()];
            modalSearchCtrl.resultsCount = data[modalSearchCtrl.countKey()];
            modalSearchCtrl.numPerPage = data.numPerPage;
            modalSearchCtrl.currentPage = data.page;
            modalSearchCtrl.queryInProgress = false;
          }).error(() => {
            modalSearchCtrl.results = [];
            modalSearchCtrl.queryInProgress = false;
          });
      };

      modalSearchCtrl.changeSearchInput = function () {
        $scope.loadWithDelay();
      };

      $scope.loadWithDelay = function () {
        // to prevent timeline from reloading too frequently
        if ($scope.timer) {
          clearTimeout($scope.timer);
        }
        if (modalSearchCtrl.searchInput) {
          $scope.timer = setTimeout(() => {
            modalSearchCtrl.loadData();
          }, 500);
        }
      };

      modalSearchCtrl.searchPlaceholderText = function () {
        return modalSearchCtrl.searchItem === 'app' ? 'Search for app or company' : 'Search for SDKs';
      };

      modalSearchCtrl.appsKey = function () {
        return modalSearchCtrl.searchItem === 'app' ? 'appData' : 'sdkData';
      };

      modalSearchCtrl.countKey = function () {
        return modalSearchCtrl.searchItem === 'app' ? 'totalAppsCount' : 'totalSdksCount';
      };

      modalSearchCtrl.seeMoreResults = function () {
        const state = modalSearchCtrl.searchItem === 'app' ? 'custom-search' : 'sdk-search';
        setTimeout(function () {
          $state.go(state, {
            item: modalSearchCtrl.searchItem,
            numPerPage: 30,
            page: 1,
            query: modalSearchCtrl.searchInput,
          }, { reload: state });
        }, 1000);
      };

      $scope.$watch('modalSearchCtrl.searchItem', () => {
        modalSearchCtrl.searchInput = '';
        modalSearchCtrl.results = null;
        modalSearchCtrl.resultsCount = null;
        modalSearchCtrl.queryInProgress = false;
      });
    },
  ]);
