import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .service('customSearchService', ['$http', function ($http) {
    return {
      customSearch(query, page, numPerPage, category, order) {
        const params = {
          query,
          numPerPage,
          page,
        };
        if (category && order) {
          params.sortBy = category;
          params.orderBy = order;
        }
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/search/apps`,
          data: params,
        });
      },
    };
  }]);
