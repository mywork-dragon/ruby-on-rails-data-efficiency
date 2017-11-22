import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('appService', appService)

appService.$inject = ['$http', 'loggitService']

function appService ($http, loggitService) {
  return {
    getAdIntelData,
    getApp,
    getAppCreatives,
    tagAsMajorApp,
    resetAppData
  }

  function getAdIntelData (platform, id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/ad_intelligence/v2/app_summaries.json',
      params: {
        platform,
        appIds: JSON.stringify([id])
      }
    })
    .then(response => response.data)
    .catch(error => {})
  }

  function getApp (platform, id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + platform + '_app',
      params: { id }
    })
    .then(response => response.data)
  }

  function getAppCreatives (platform, id, pageNum, pageSize, networks, formats) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/ad_intelligence/v2/creatives.json',
      params: {
        platform,
        appIds: JSON.stringify([id]),
        pageNum,
        pageSize,
        sourceIds: JSON.stringify(networks),
        formats: JSON.stringify(formats)
      }
    })
    .then(response => {
      const data = response.data;
      const obj = {}
      obj.results = data.results[id] ? data.results[id].creatives : []
      obj.resultsCount = data.resultsCount;
      obj.pageNum = data.pageNum;
      obj.pageSize = data.pageSize;

      return obj
    })
    .catch(error => {
      return {
        results: [],
        resultsCount: 0,
        pageNum,
        pageSize
      }
    })
  }

  function resetAppData (appId) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/ios_reset_app_data',
      params: { appId }
    })
    .then(response => response.data)
  }

  function tagAsMajorApp (appId, platform) {
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/admin/major_apps/tag`,
      params: { appId, platform }
    })
    .then(function(response) {
      loggitService.logSuccess('App successfully tagged.')
      return response.data;
    })
  }
}
