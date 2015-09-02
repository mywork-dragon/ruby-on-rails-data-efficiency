'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService',
    function($rootScope, customSearchService, $httpParamSerializer, $location, listApiService) {

      var customSearchCtrl = this;

      customSearchCtrl.platform = 'ios'; // default

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {

        customSearchCtrl.queryInProgress = true;

        var urlParams = $location.url().split('/search/custom')[1]; // Get url params
        var routeParams = $location.search();

        customSearchService.customSearch(routeParams.platform, routeParams.query, routeParams.page, routeParams.numPerPage)
          .success(function(data) {
            customSearchCtrl.apps = data.appData;
            customSearchCtrl.appNum = data.appData.length;
            customSearchCtrl.numApps = data.totalAppsCount;
            customSearchCtrl.numPerPage = data.numPerPage;
            customSearchCtrl.changeAppPlatform(routeParams.platform);
            customSearchCtrl.searchInput = routeParams.query;
            customSearchCtrl.currentPage = data.page;
            customSearchCtrl.queryInProgress = false;
          })
          .error(function(data) {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
            customSearchCtrl.queryInProgress = false;
          });

      };

      customSearchCtrl.loadTableData();

      customSearchCtrl.changeAppPlatform = function(platform) {
        customSearchCtrl.platform = platform;
      };

      customSearchCtrl.onPageChange = function(nextPage) {
        console.log('NEXT PAGE', nextPage);
        customSearchCtrl.submitSearch(nextPage);
      };

      customSearchCtrl.submitSearch = function(newPageNum) {
        var payload = {
          query: customSearchCtrl.searchInput,
          platform: customSearchCtrl.platform,
          page: newPageNum || 1,
          numPerPage: 5
        };
        $location.url('/search/custom?' + $httpParamSerializer(payload));
        customSearchCtrl.loadTableData();
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Custom Search", {
            "query": customSearchCtrl.searchInput,
            "platform": customSearchCtrl.platform
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      customSearchCtrl.addSelectedTo = function(list, selectedApps) {
        listApiService.addSelectedTo(list, selectedApps, customSearchCtrl.platform).success(function() {
          customSearchCtrl.notify('add-selected-success');
          $rootScope.selectedAppsForList = [];
        }).error(function() {
          customSearchCtrl.notify('add-selected-error');
        });
        $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
      };

      customSearchCtrl.notify = function(type) {
        listApiService.listAddNotify(type);
      };

      customSearchCtrl.appsDisplayedCount = function() {
        console.log('NUM PER PAGE', customSearchCtrl.numPerPage);
        console.log('CURRENT PAGE', customSearchCtrl.currentPage);

        var lastPageMaxApps = customSearchCtrl.numPerPage * customSearchCtrl.currentPage;
        var baseAppNum = customSearchCtrl.numPerPage * (customSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > customSearchCtrl.numApps) {
          return "" + baseAppNum + " - " + customSearchCtrl.numApps;
        } else {
          return "" + baseAppNum + " - " + lastPageMaxApps;
        }
      };

    }
  ]);
