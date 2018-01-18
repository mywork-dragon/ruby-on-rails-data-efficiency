import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('apiTokenService', ['$http', 'loggitService', function ($http, loggitService) {
    return {
      getApiTokens(id) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/admin/get_api_tokens`,
          params: { account_id: id },
        });
      },
      generateToken(id, rateLimit, rateWindow) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/admin/generate_api_token`,
          params: {
            account_id: id,
            rate_limit: rateLimit,
            rate_window: rateWindow,
          },
        });
      },
      deleteToken(id) {
        return $http({
          method: 'PUT',
          url: `${API_URI_BASE}api/admin/delete_api_token`,
          params: { token_id: id },
        });
      },
      updateToken(id, data) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/admin/update_api_token`,
          params: {
            id,
            data,
          },
        });
      },
      toast(type) {
        switch (type) {
          case 'token-create-success':
            return loggitService.logSuccess('Token was created successfully.');
          case 'token-create-failure':
            return loggitService.logError('Error! Something went wrong while creating your token.');
          case 'token-update-success':
            return loggitService.logSuccess('Token was updated successfully.');
          case 'token-update-failure':
            return loggitService.logError('Error! Something went wrong while updating your token.');
          case 'token-delete-success':
            return loggitService.logSuccess('Token was deleted successfully.');
          case 'token-delete-failure':
            return loggitService.logError('Error! Something went wrong while deleting your token.');
        }
      },
    };
  }]);
