'use strict';

angular.module('appApp')
  .service('sdkSearchService', ['$http', function($http) {
    return {
      sdkSearch: function(query, page, numPerPage, platform) {
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
