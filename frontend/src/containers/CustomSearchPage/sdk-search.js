import angular from 'angular';

angular.module('appApp')
  .controller('SdkSearchCtrl', ['$rootScope', 'sdkSearchService', '$httpParamSerializer', '$location', '$state', '$scope',
    function($rootScope, sdkSearchService, $httpParamSerializer, $location, $state, $scope) {
      const sdkSearchCtrl = this;

      /* For query load when /search/:query path hit */
      sdkSearchCtrl.loadTableData = function() {
        sdkSearchCtrl.queryInProgress = true;

        const routeParams = $location.search();

        sdkSearchService.sdkSearch(routeParams.query, routeParams.page, routeParams.numPerPage)
          .success((data) => {
            sdkSearchCtrl.sdks = data.sdkData;
            sdkSearchCtrl.sdkNum = data.sdkData.length;
            sdkSearchCtrl.numSdks = data.totalSdksCount;
            sdkSearchCtrl.numPerPage = data.numPerPage;
            sdkSearchCtrl.searchInput = routeParams.query;
            sdkSearchCtrl.currentPage = data.page;
            sdkSearchCtrl.queryInProgress = false;
          })
          .error(() => {
            sdkSearchCtrl.sdkNum = 0;
            sdkSearchCtrl.numSdks = 0;
            sdkSearchCtrl.queryInProgress = false;
          });
      };

      sdkSearchCtrl.loadTableData();

      sdkSearchCtrl.sdksDisplayedCount = function() {
        const lastPageMaxApps = sdkSearchCtrl.numPerPage * sdkSearchCtrl.currentPage;
        const baseAppNum = sdkSearchCtrl.numPerPage * (sdkSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > sdkSearchCtrl.numSdks) {
          return `${baseAppNum} - ${sdkSearchCtrl.numSdks}`;
        }
        return `${baseAppNum} - ${lastPageMaxApps}`;
      };
    },
  ]);
