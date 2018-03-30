import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp').factory('savedSearchApiService', ['$http', 'loggitService', 'AppPlatform', function($http, loggitService) {
  return {
    getSavedSearches() {
      return $http({
        method: 'GET',
        url: `${API_URI_BASE}api/saved_searches/get`,
      });
    },
    createSavedSearch(name, queryString) {
      return $http({
        method: 'POST',
        url: `${API_URI_BASE}api/saved_searches/create`,
        params: { name, queryString, version: 'v1' },
      });
    },
    updateSavedSearch(id, queryString) {
      return $http({
        method: 'PUT',
        url: `${API_URI_BASE}api/saved_searches/edit`,
        params: { id, queryString },
      });
    },
    deleteSavedSearch(id) {
      return $http({
        method: 'PUT',
        url: `${API_URI_BASE}api/saved_searches/delete`,
        params: { id },
      });
    },
    toast(type) {
      switch (type) {
        case 'search-create-success':
          return loggitService.logSuccess('Search was created successfully.');
        case 'search-create-failure':
          return loggitService.logError('Error! Something went wrong while creating your search.');
        case 'search-update-success':
          return loggitService.logSuccess('Search was updated successfully.');
        case 'search-update-failure':
          return loggitService.logError('Error! Something went wrong while updating your search.');
        case 'search-delete-success':
          return loggitService.logSuccess('Search was deleted successfully.');
        case 'search-delete-failure':
          return loggitService.logError('Error! Something went wrong while deleting your search.');
      }
    },
  };
}]);
