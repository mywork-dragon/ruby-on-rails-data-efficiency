'use strict';

/**************************
 App ui Services

 **************************/

angular.module("appApp").factory("apiService", ['$http', function($http) {

  return {
    postDashboardSearch: function(text) {
      console.log(text);
      /*
       postDashboardSearch: $http({
        method: 'POST',
        url: 'https://www.example.com/api/v1/page',
        params: 'limit=10, sort_by=created:desc'
      });
      },
      getApp: function() {
        return $http({
          method: 'GET',
          url: 'https://www.example.com/api/v1/page',
          params: 'limit=10, sort_by=created:desc'
        });
      },
      getCompany: function() {
        return $http({
          method: 'GET',
          url: 'https://www.example.com/api/v1/page',
          params: 'limit=10, sort_by=created:desc'
        });
       */
    }
  }
}]);
