'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$rootScope', 'customSearchService', '$httpParamSerializer', '$location', function($rootScope, customSearchService, $httpParamSerializer, $location) {

    var customSearchCtrl = this;

    customSearchCtrl.platform = 'ios'; // default

    /* For query load when /search/:query path hit */
    customSearchCtrl.loadTableData = function() {

      var urlParams = $location.url().split('/search/custom')[1]; // Get url params
      var routeParams = $location.search();

      customSearchService.customSearch(routeParams.platform, routeParams.query)
        .success(function(data) {
          $rootScope.apps = data;
          $rootScope.appNum = data.length;
          $rootScope.numApps = data.length;
        })
        .error(function(data) {
          $rootScope.appNum = 0;
          $rootScope.numApps = 0;
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
        numPerPage: 100

      };
      $location.url('/search/custom?' + $httpParamSerializer(payload));
      customSearchCtrl.loadTableData();

    }

  }]);
