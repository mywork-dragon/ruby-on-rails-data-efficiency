import angular from 'angular';
const API_URI_BASE = window.API_URI_BASE;

(function() {
    'use strict';

    angular
        .module('appApp')
        .factory('adIntelService', adIntelService);

    adIntelService.$inject = ['$http'];

    /* @ngInject */
    function adIntelService($http) {
        var service = {
          getAdIntelApps,
          getAdSources
        };

        return service;

        function getAdIntelApps (platform, page, order, category, adNetworks) {
          const platforms = platform == 'all' ? ['ios', 'android'] : [platform];
          return $http({
            method: 'GET',
            url: API_URI_BASE + 'api/ad_intelligence/v2/query.json',
            params: {
              pageNum: page,
              orderBy: order,
              sortBy: category,
              sourceIds: JSON.stringify(adNetworks),
              platforms: JSON.stringify(platforms)
            }
          })
        }

        function getAdSources () {
          return $http({
            method: 'GET',
            url: API_URI_BASE + 'api/ad_intelligence/v2/ad_sources'
          })
          .then(function(response) {
            const networks = response.data;
            for (var id in networks) {
              networks[id].active = networks[id].can_access;
            }
            return networks;
          })
        }
    }
})();
