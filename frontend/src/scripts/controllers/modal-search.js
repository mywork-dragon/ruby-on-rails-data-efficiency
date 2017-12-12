import angular from 'angular';

angular.module('appApp')
  .controller('ModalSearchCtrl', ['$scope', 'customSearchService',
    function ($scope, customSearchService) {
      const modalSearchCtrl = this;
      modalSearchCtrl.platform = window.APP_PLATFORM; // default
      modalSearchCtrl.results = null;

      /* For query load when /search/:query path hit */
      modalSearchCtrl.loadData = function () {
        modalSearchCtrl.queryInProgress = true;
        customSearchService.customSearch(modalSearchCtrl.platform, modalSearchCtrl.searchInput, 1, 10)
          .success((data) => {
            modalSearchCtrl.results = data[modalSearchCtrl.appsKey()];
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
        if (modalSearchCtrl.platform === 'ios') {
          return 'Search for iOS app or company';
        } else if (modalSearchCtrl.platform === 'android') {
          return 'Search for Android app or company';
        } else if (modalSearchCtrl.platform === 'androidSdks') {
          return 'Search for Android SDKs';
        } else if (modalSearchCtrl.platform === 'iosSdks') {
          return 'Search for iOS SDKs';
        }
      };

      modalSearchCtrl.appsKey = function () {
        if (modalSearchCtrl.platform === 'ios') {
          return 'appData';
        } else if (modalSearchCtrl.platform === 'android') {
          return 'appData';
        } else if (modalSearchCtrl.platform === 'androidSdks') {
          return 'sdkData';
        } else if (modalSearchCtrl.platform === 'iosSdks') {
          return 'sdkData';
        }
      };

      $scope.$watch('modalSearchCtrl.platform', () => {
        modalSearchCtrl.searchInput = '';
        modalSearchCtrl.results = null;
        modalSearchCtrl.queryInProgress = false;
      });
    },
  ]);
