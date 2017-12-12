import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .service('adManagerService', adManagerService);

adManagerService.$inject = ['$http', 'loggitService'];

function adManagerService($http, loggitService) {
  return {
    getAccountSettings,
    updateAccountSettings,
  };

  function getAccountSettings(id) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/ad_intelligence/v2/account_settings`,
      params: { account_id: id },
    })
      .then(response => response.data);
  }

  function updateAccountSettings(id, settings) {
    return $http({
      method: 'PUT',
      url: `${API_URI_BASE}api/ad_intelligence/v2/update_account_settings`,
      params: { account_id: id, settings: JSON.stringify(settings) },
    })
      .then((response) => {
        loggitService.logSuccess('Settings were successfully updated!');
        return response.data;
      })
      .catch(() => loggitService.logError('There was a problem updating the settings.'));
  }
}
