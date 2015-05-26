'use strict';

angular.module("appApp")
  .factory("apiService", ['$http', function($http) {
    return {
      /* Translates tag object values into a request object that matches format of back end api endpoints */
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
          url: API_URI_BASE + 'api/filter_' + APP_PLATFORM + '_apps',
          data: requestData
        });
      },
      getCategories: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        });
      }
    };
  }])
  .factory("authToken", [function() {
    return {
      setToken: function(payload) {
        localStorage.setItem('custom_auth_token', payload);
      },
      isAuthenticated: function() {
        return localStorage.getItem('custom_auth_token') != null;
      }
    }
  }])
  .factory("authEvents", [function() {
    return {
      loginSuccess: "STRING_REPRESENTS_EVENT_SUCCESS",
      loginFailed: "STRING_REPRESENTS_EVENT_FAILURE"
    }
  }])
  .factory("authService", ["$http", "$q", "$rootScope", "authToken", "authEvents", function($http, $q, $rootScope, authToken, authEvents) {
    return {
      login: function(email, password) {
        var d = $q.defer();
        $http.post("/auth/login", {
          email: email,
          password: password
        }).success(function(resp) {

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.identify(email);
          mixpanel.people.set({
            "$email": email
          });
          mixpanel.track(
            "Login Success"
          );
          /* -------- Mixpanel Analytics End -------- */

          authToken.setToken(resp.auth_token);
          $rootScope.$broadcast(authEvents.loginSuccess);
          console.log(authEvents.loginSuccess);
          console.log(resp);
          d.resolve(resp.user);
        }).error(function(resp) {
          $rootScope.$broadcast(authEvents.loginFailed);
          console.log(authEvents.loginFailed);
          console.log(resp);
          d.reject(resp.error);
        });
        return d.promise;
      }
    };
  }]);

