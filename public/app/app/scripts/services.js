'use strict';

/**************************
 App ui Services

 **************************/

angular.module("appApp").factory("apiService", ['$http', function($http) {

  return {
    postDashboardSearch: function(text) {
      return $http({
        method: 'POST',
        headers: {
          'Content-Type': 'json'
        },
        url: 'http://mightysignal.com/api/filter_ios_apps',
        data: {"app": {"adSpend": "true"}}
      }).success(function(data) {
        console.log(data);
      });
    }
  };
}]);

/*
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
