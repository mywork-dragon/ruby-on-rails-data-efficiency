'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService',
    function($rootScope, customSearchService, $httpParamSerializer, $location, listApiService) {

      var customSearchCtrl = this;

      customSearchCtrl.platform = 'ios'; // default

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {

        var urlParams = $location.url().split('/search/custom')[1]; // Get url params
        var routeParams = $location.search();

        customSearchService.customSearch(routeParams.platform, routeParams.query, routeParams.page, routeParams.numPerPage)
          .success(function(data) {
            customSearchCtrl.apps = data;
            customSearchCtrl.appNum = data.length;
            customSearchCtrl.numApps = data.length;
            customSearchCtrl.searchInput = routeParams.query;
            customSearchCtrl.changeAppPlatform(routeParams.platform);
          })
          .error(function(data) {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
          });

      };

      customSearchCtrl.loadTableData();

      customSearchCtrl.changeAppPlatform = function(platform) {
        customSearchCtrl.platform = platform;
      };

      customSearchCtrl.submitSearch = function() {
        var payload = {
          query: customSearchCtrl.searchInput,
          platform: customSearchCtrl.platform,
          page: 0,
          numPerPage: 50
        };
        $location.url('/search/custom?' + $httpParamSerializer(payload));
        customSearchCtrl.loadTableData();
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
      }
    }
  ]);
