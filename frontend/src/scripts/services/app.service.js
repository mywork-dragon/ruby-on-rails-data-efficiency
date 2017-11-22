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
    .catch(error => {
      return {"698":{"ad_networks":[{"id":"mopub","name":"MoPub","ad_formats":[{"id":"interstitial","name":"Interstitial"}],"creative_formats":["html"],"number_of_creatives":1,"first_seen_ads_date":"2017-11-19T05:00:59.468+00:00","last_seen_ads_date":"2017-11-19T05:00:59.468+00:00"},{"id":"applovin","name":"Applovin","ad_formats":[{"id":"interstitial","name":"Interstitial"}],"creative_formats":["html","video"],"number_of_creatives":6587,"first_seen_ads_date":"2017-10-16T23:45:19.125+00:00","last_seen_ads_date":"2017-11-22T01:40:56.382+00:00"}],"creative_formats":["html","video"],"first_seen_ads_date":"2017-10-16T23:45:19.125+00:00","last_seen_ads_date":"2017-11-22T01:40:56.382+00:00","ad_attribution_sdks":[{"id":5,"name":"Adjust","website":"http://adjust.com","favicon":"https://www.google.com/s2/favicons?domain=adjust.com","last_seen_date":"2017-11-19T20:57:01.000Z","first_seen_date":"2017-07-26T11:30:23.000Z"}],"number_of_creatives":6588,"icon":"https://is3-ssl.mzstatic.com/image/thumb/Purple111/v4/8e/99/9d/8e999d2e-8b04-3c0c-3f6d-9761e6349334/source/100x100bb.jpg"}}
    })
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
