import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('popularAppsService', popularAppsService);

popularAppsService.$inject = ['$http'];

function popularAppsService ($http) {
  return {
    getTrending,
    getNewcomers,
    getChart,
    rankChangeColor,
    rankColor,
  };

  function getTrending (params) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/popular_apps/trending.json`,
      params,
    })
      .then(response => response.data);
  }

  function getNewcomers(params) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/popular_apps/newcomers.json`,
      params,
    })
      .then(response => response.data);
  }

  function getChart(params) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/popular_apps/top_app_chart.json`,
      params,
    })
      .then(response => response.data);
  }

  function rankColor(change) {
    if (change <= 100) {
      return 'green';
    }
    return '';
  }

  function rankChangeColor(change) {
    if (change > 500) {
      return 'green';
    } else if (change > 200) {
      return 'light-green';
    } else if (change > 0) {
      return 'black';
    } else if (change >= -200) {
      return 'light-red';
    } else if (change < -200) {
      return 'dark-red';
    }
  }
}
