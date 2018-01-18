import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('adIntelService', adIntelService);

adIntelService.$inject = ['$http'];

/* @ngInject */
function adIntelService($http) {
  const service = {
    getAdIntelApps,
    getAdSources,
  };

  return service;

  function getAdIntelApps(platform, page, order, category, adNetworks) {
    const platforms = platform === 'all' ? ['ios', 'android'] : [platform];
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/ad_intelligence/v2/query.json`,
      params: {
        pageNum: page,
        orderBy: order,
        sortBy: category,
        sourceIds: JSON.stringify(adNetworks),
        platforms: JSON.stringify(platforms),
      },
    });
  }

  function getAdSources() {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/ad_intelligence/v2/ad_sources`,
    })
      .then((response) => {
        const networks = response.data;
        for (const id in networks) {
          if (Object.prototype.hasOwnProperty.call(networks, id)) {
            networks[id].active = networks[id].can_access;
          }
        }
        return networks;
      });
  }
}
