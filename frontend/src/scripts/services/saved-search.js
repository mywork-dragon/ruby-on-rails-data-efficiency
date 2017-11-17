import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular.module("appApp").factory("savedSearchApiService", ["$http", "loggitService", "AppPlatform", function($http, loggitService, AppPlatform) {
  return {
    getSavedSearches: function() {
      return $http({
        method: 'GET',
        url: `${API_URI_BASE}api/saved_searches/get`
      });
    },
    createSavedSearch: function(name, queryString) {
      return $http({
        method: 'POST',
        url: `${API_URI_BASE}api/saved_searches/create`,
        params: { name, queryString }
      })
    },
    updateSavedSearch: function(id, queryString) {
      return $http({
        method: 'PUT',
        url: `${API_URI_BASE}api/saved_searches/edit`,
        params: { id, queryString }
      })
    },
    deleteSavedSearch: function(id) {
      return $http({
        method: 'PUT',
        url: `${API_URI_BASE}api/saved_searches/delete`,
        params: { id }
      })
    },
    toast: function(type) {
      switch (type) {
        case 'search-create-success':
          return loggitService.logSuccess("Search was created successfully.");
        case 'search-create-failure':
          return loggitService.logError("Error! Something went wrong while creating your search.")
        case 'search-update-success':
          return loggitService.logSuccess("Search was updated successfully.");
        case 'search-update-failure':
          return loggitService.logError("Error! Something went wrong while updating your search.")
        case 'search-delete-success':
          return loggitService.logSuccess("Search was deleted successfully.");
        case 'search-delete-failure':
          return loggitService.logError("Error! Something went wrong while deleting your search.")
      }
    }
  }
}]);
