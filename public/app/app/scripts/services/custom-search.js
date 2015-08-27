'use strict';

angular.module('appApp')
  .service('customSearchService', ['$http', function($http) {
    return {
      customSearch: function(platform, query, page, numPerPage) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/search/' + platform,
          data: {
            query: query,
            numPerPage: numPerPage,
            page: page
          }
        });
      }
    }
  }]);
