'use strict';

// Manual auth based off guide: http://adamalbrecht.com/2014/12/04/add-json-web-token-authentication-to-your-angular-rails-app/

angular.module("appApp")
  .factory("authToken", ["$window", function($window) {
    return {
      setToken: function(payload) {
        localStorage.setItem(JWT_TOKEN_NAME, payload);
      },
      isAuthenticated: function() {
        return localStorage.getItem(JWT_TOKEN_NAME) != null;
      },
      get: function() {
        return localStorage.getItem(JWT_TOKEN_NAME);
      },
      deleteToken: function() {
        localStorage.removeItem(JWT_TOKEN_NAME);
        $window.location.href = "#/login";
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
            "$email": email,
            "jwtToken": resp.auth_token
          });
          // If on production
          if (API_URI_BASE.indexOf('mightysignal.com') >= 0) {
            mixpanel.track(
              "Login Success"
            );
            /* -------- Mixpanel Analytics End -------- */
            /* -------- Slacktivity Alerts -------- */
            window.Slacktivity.send({
              "Login Status": "Success",
              "User Email": email
            });
          }
          /* -------- Slacktivity Alerts End -------- */

          authToken.setToken(resp.auth_token);
          $rootScope.$broadcast(authEvents.loginSuccess);
          d.resolve(resp.user);
        }).error(function(resp) {
          $rootScope.$broadcast(authEvents.loginFailed);
          d.reject(resp.error);
        });
        return d.promise;
      },
      permissions: function() {
        return $http.get('/auth/permissions');
      },
      userInfo: function() {
        return $http.get('/auth/user/info');
      }
    };
  }])
  .factory("authInterceptor", ["$q", "$injector", function($q, $injector) {
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
  }]);
