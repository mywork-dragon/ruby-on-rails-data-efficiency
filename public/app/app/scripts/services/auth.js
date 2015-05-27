'use strict';

// Manual auth based off guide: http://adamalbrecht.com/2014/12/04/add-json-web-token-authentication-to-your-angular-rails-app/

angular.module("appApp")
  .factory("authToken", [function() {
    return {
      setToken: function(payload) {
        localStorage.setItem('jwt_auth_token', payload);
      },
      isAuthenticated: function() {
        return localStorage.getItem('jwt_auth_token') != null;
      },
      get: function() {
        return localStorage.getItem('jwt_auth_token');
      }
    }
  }])
  .factory("authEvents", [function() {
    return {
      loginSuccess: "STRING_REPRESENTS_EVENT_SUCCESS",
      loginFailed: "STRING_REPRESENTS_EVENT_FAILED_LOGIN",
      notAuthenticated: "STRING_REPRESENTS_EVENT_FAILED_AUTH",
      notAuthorized: "STRING_REPRESENTS_EVENT_FAILURE_NOT_AUTHORIZED",
      sessionTimeout: "STRING_REPRESENTS_EVENT_FAILURE_TIMEOUT"
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
          d.resolve(resp.user);
        }).error(function(resp) {
          $rootScope.$broadcast(authEvents.loginFailed);
          d.reject(resp.error);
        });
        return d.promise;
      }
    };
  }])
  .factory("authInterceptor", function($q, $injector) {
    return {
      // This will be called on every outgoing http request
      request: function(config) {
        var authToken = $injector.get("authToken");
        var token = authToken.get();
        config.headers = config.headers || {};
        if (token) {
          config.headers.Authorization = "Bearer " + token;
        }
        return config || $q.when(config);
      },
      // This will be called on every incoming response that has en error status code
      responseError: function(response) {
        var authEvents = $injector.get('authEvents');
        var matchesAuthenticatePath = response.config && response.config.url.match(new RegExp('/api/auth'));
        if (!matchesAuthenticatePath) {
          $injector.get('$rootScope').$broadcast({
            401: authEvents.notAuthenticated,
            403: authEvents.notAuthorized,
            419: authEvents.sessionTimeout
          }[response.status], response);
        }
        return $q.reject(response);
      }
    };
  });
