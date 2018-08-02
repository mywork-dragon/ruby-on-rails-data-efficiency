import angular from 'angular';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .service('sdkSearchService', ['$http', function($http) {
    return {
      sdkSearch(query, page, numPerPage) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/search/sdks`,
          data: {
            query,
            numPerPage,
            page,
          },
        });
      },
    };
  }]);
