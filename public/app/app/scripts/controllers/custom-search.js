'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$rootScope', 'customSearchService', function($rootScope, customSearchService) {

    var customSearchCtrl = this;

    customSearchCtrl.platform = 'ios'; // default

    customSearchCtrl.changeAppPlatform = function(platform) {
      customSearchCtrl.platform = platform;
    };

    customSearchCtrl.submitSearch = function() {

      customSearchService.customSearch(customSearchCtrl.platform, customSearchCtrl.searchInput)
        .success(function(data) {
          $rootScope.apps = data;
          $rootScope.appNum = data.length;
          $rootScope.numApps = data.length;
        })
        .error(function(data) {

        });

    }

  }]);
