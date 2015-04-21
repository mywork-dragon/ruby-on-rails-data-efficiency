'use strict';

angular.module("appApp").factory("apiService", ['$http', function($http) {
  return {
    searchRequestPost: function(tags, currentPage, numPerPage, category, order) {
      var requestData = {app: {}, company: {}};
      if(tags) {
        tags.forEach(function (tag) {
          switch (tag.parameter) {
            case 'mobilePriority':
              if(requestData['app'][tag.parameter]) {
                requestData['app'][tag.parameter].push(tag.value);
              } else {
                requestData['app'][tag.parameter] = [tag.value];
              }
              break;
            case 'adSpend':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'userBases':
              if(requestData['app'][tag.parameter]) {
                requestData['app'][tag.parameter].push(tag.value);
              } else {
                requestData['app'][tag.parameter] = [tag.value];
              }
              break;
            case 'updatedDaysAgo':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'categories':
              if(requestData['app'][tag.parameter]) {
                requestData['app'][tag.parameter].push(tag.value);
              } else {
                requestData['app'][tag.parameter] = [tag.value];
              }
              break;
            case 'fortuneRank':
              requestData['company'][tag.parameter] = tag.value;
              break;
            case 'customKeywords':
              if(requestData[tag.parameter]) {
                requestData[tag.parameter].push(tag.value);
              } else {
                requestData[tag.parameter] = [tag.value];
              }
              break;
          }
        });
      }
      if (currentPage && numPerPage) {
        requestData.pageNum = currentPage;
        requestData.pageSize = numPerPage;
      }
      if (category && order) {
        requestData.sortBy = category;
        requestData.orderBy = order;
      }
      return $http({
        method: 'POST',
        //url: 'http://mightysignal.com/api/filter_ios_apps',
        url: 'http://localhost:3000/api/filter_ios_apps',
        data: requestData
      });
    }
  };
}]);


/*
angular.module("appApp").factory("AuthService", ['$http', '$q', '$rootScope', 'AuthToken', 'AuthEvents', function($http, $q, $rootScope, AuthToken, AuthEvents) {
  return {
    login: function(email, password) {
      var d = $q.defer();
      $http.post('/auth', {
        email: email,
        password: password
      }).success(function(resp) {
        AuthToken.set(resp.auth_token);
        $rootScope.$broadcast(AuthEvents.loginSuccess);
        d.resolve(resp.user);
      }).error(function(resp) {
        $rootScope.$broadcast(AuthEvents.loginFailed);
        d.reject(resp.error);
      });
      return d.promise;
    }
  };
}]);
*/
