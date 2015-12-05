'use strict';

angular.module('appApp')
  .controller('SdkSearchCtrl', ['$rootScope', 'sdkSearchService', '$httpParamSerializer', '$location', 'listApiService',
    function($rootScope, sdkSearchService, $httpParamSerializer, $location, listApiService) {

      var sdkSearchCtrl = this;

      /* For query load when /search/:query path hit */
      sdkSearchCtrl.loadTableData = function() {

        sdkSearchCtrl.queryInProgress = true;

        var urlParams = $location.url().split('/search/sdk')[1]; // Get url params
        var routeParams = $location.search();

        sdkSearchService.sdkSearch(routeParams.query, routeParams.page, routeParams.numPerPage, routeParams.platform)
          .success(function(data) {
            sdkSearchCtrl.sdks = data.sdkData;
            sdkSearchCtrl.sdkNum = data.sdkData.length;
            sdkSearchCtrl.numSdks = data.totalSdksCount;
            sdkSearchCtrl.numPerPage = data.numPerPage;
            sdkSearchCtrl.changeAppPlatform(routeParams.platform);
            sdkSearchCtrl.searchInput = routeParams.query;
            sdkSearchCtrl.currentPage = data.page;
            sdkSearchCtrl.queryInProgress = false;
          })
          .error(function(data) {
            sdkSearchCtrl.sdkNum = 0;
            sdkSearchCtrl.numSdks = 0;
            sdkSearchCtrl.queryInProgress = false;
          });

      };

      sdkSearchCtrl.loadTableData();

      sdkSearchCtrl.changeAppPlatform = function(platform) {
        sdkSearchCtrl.platform = platform;
      };

      sdkSearchCtrl.sdksDisplayedCount = function() {
        var lastPageMaxApps = sdkSearchCtrl.numPerPage * sdkSearchCtrl.currentPage;
        var baseAppNum = sdkSearchCtrl.numPerPage * (sdkSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > sdkSearchCtrl.numSdks) {
          return "" + baseAppNum + " - " + sdkSearchCtrl.numSdks;
        } else {
          return "" + baseAppNum + " - " + lastPageMaxApps;
        }
      };

    }
  ]);
