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

        sdkSearchService.sdkSearch(routeParams.query, routeParams.page, routeParams.numPerPage)
          .success(function(data) {
            sdkSearchCtrl.sdks = data.sdkData;
            sdkSearchCtrl.appNum = data.sdkData.length;
            sdkSearchCtrl.numApps = data.totalAppsCount;
            sdkSearchCtrl.numPerPage = data.numPerPage;
            sdkSearchCtrl.changeAppPlatform(routeParams.platform);
            sdkSearchCtrl.searchInput = routeParams.query;
            sdkSearchCtrl.currentPage = data.page;
            sdkSearchCtrl.queryInProgress = false;
          })
          .error(function(data) {
            sdkSearchCtrl.appNum = 0;
            sdkSearchCtrl.numApps = 0;
            sdkSearchCtrl.queryInProgress = false;
          });

      };

      sdkSearchCtrl.loadTableData();

      sdkSearchCtrl.changeAppPlatform = function(platform) {
        sdkSearchCtrl.platform = platform;
      };

      sdkSearchCtrl.onPageChange = function(nextPage) {
        sdkSearchCtrl.submitSearch(nextPage);
      };

      sdkSearchCtrl.submitSearch = function(newPageNum) {
        var payload = {
          query: sdkSearchCtrl.searchInput,
          platform: sdkSearchCtrl.platform,
          page: newPageNum || 1,
          numPerPage: 30
        };
        $location.url('/search/custom?' + $httpParamSerializer(payload));
        sdkSearchCtrl.loadTableData();
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Custom Search", {
            "query": sdkSearchCtrl.searchInput,
            "platform": sdkSearchCtrl.platform
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      sdkSearchCtrl.searchPlaceholderText = function() {
        if(sdkSearchCtrl.platform == 'ios') {
          return 'Search for iOS app or company';
        } else if(sdkSearchCtrl.platform == 'sdks') {
          return 'Search for SDKs';
        } else {
          return 'Search for Android app or company';
        }
      };

      sdkSearchCtrl.addSelectedTo = function(list, selectedApps) {
        listApiService.addSelectedTo(list, selectedApps, sdkSearchCtrl.platform).success(function() {
          sdkSearchCtrl.notify('add-selected-success');
          $rootScope.selectedAppsForList = [];
        }).error(function() {
          sdkSearchCtrl.notify('add-selected-error');
        });
        $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
      };

      sdkSearchCtrl.notify = function(type) {
        listApiService.listAddNotify(type);
      };

      sdkSearchCtrl.appsDisplayedCount = function() {
        var lastPageMaxApps = sdkSearchCtrl.numPerPage * sdkSearchCtrl.currentPage;
        var baseAppNum = sdkSearchCtrl.numPerPage * (sdkSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > sdkSearchCtrl.numApps) {
          return "" + baseAppNum + " - " + sdkSearchCtrl.numApps;
        } else {
          return "" + baseAppNum + " - " + lastPageMaxApps;
        }
      };

    }
  ]);
