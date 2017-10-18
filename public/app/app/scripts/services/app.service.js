angular
  .module('appApp')
  .factory('appService', appService)

appService.$inject = ['$http', 'loggitService']

function appService ($http, loggitService) {
  return {
    getApp,
    tagAsMajorApp,
    resetAppData
  }

  function getApp (platform, id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + platform + '_app',
      params: { id }
    })
    .then(function(response) {
      return response.data;
    })

  }

  function resetAppData (appId) {
    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/admin/ios_reset_app_data',
      params: { appId }
    })
    .then(function(response) {
      return response.data;
    })
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
