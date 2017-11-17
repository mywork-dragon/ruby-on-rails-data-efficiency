import angular from 'angular';
import mixpanel from 'mixpanel-browser';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .service('customSearchService', ['$http', function($http) {
    return {
      customSearch: function(platform, query, page, numPerPage, category, order) {
        var params = {
          query: query,
          numPerPage: numPerPage,
          page: page
        }
        if (category && order) {
          params.sortBy = category
          params.orderBy = order
        }
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/search/' + platform,
          data: params
        });
      }
    }
  }]);
