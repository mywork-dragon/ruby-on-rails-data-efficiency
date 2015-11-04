'use strict';

angular.module('appApp')
  .service('sdkSearchService', ['$http', function($http) {
    return {
      sdkSearch: function(query, page, numPerPage) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/search/sdk',
          data: {
            query: query,
            numPerPage: numPerPage,
            page: page
          }
        });
      }
    }
  }]);
