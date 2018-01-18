import angular from 'angular';
import mixpanel from 'mixpanel-browser';

// Manual auth based off guide: http://adamalbrecht.com/2014/12/04/add-json-web-token-authentication-to-your-angular-rails-app/

const JWT_TOKEN_NAME = window.JWT_TOKEN_NAME;
const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('authToken', ['$window', function ($window) {
    return {
      setToken(payload) {
        localStorage.setItem(JWT_TOKEN_NAME, payload);
      },
      isAuthenticated() {
        return localStorage.getItem(JWT_TOKEN_NAME) != null;
      },
      get() {
        return localStorage.getItem(JWT_TOKEN_NAME);
      },
      deleteToken(message) {
        localStorage.removeItem(JWT_TOKEN_NAME);
        let location = '#/login';
        if (message) {
          location += `?msg=${message}`;
        }
        $window.location.href = location;
      },
    };
  }])
  .factory('authEvents', [function () {
    return {
      loginSuccess: 'STRING_REPRESENTS_EVENT_SUCCESS',
      loginFailed: 'STRING_REPRESENTS_EVENT_FAILED_LOGIN',
      notAuthenticated: 'STRING_REPRESENTS_EVENT_FAILED_AUTH',
      notAuthorized: 'STRING_REPRESENTS_EVENT_FAILURE_NOT_AUTHORIZED',
      sharedAuthentication: 'STRING_REPRESENTS_AUTHENTICATION_SHARED',
      sessionTimeout: 'STRING_REPRESENTS_EVENT_FAILURE_TIMEOUT',
      authRevoked: 'STRING_REPRESENTS_AUTHORIZATION_REVOKED',
    };
  }])
  .factory('authService', ['$http', '$q', '$rootScope', 'authToken', 'authEvents', function ($http, $q, $rootScope, authToken, authEvents) {
    let ref = '';
    return {
      login(email, password) {
        const d = $q.defer();
        $http.post('/auth/login', {
          email,
          password,
        }).success((resp) => {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.identify(email);
          mixpanel.people.set({
            $email: email,
            jwtToken: resp.auth_token,
          });
          // If on production
          if (API_URI_BASE.indexOf('mightysignal.com') >= 0) {
            mixpanel.track(
              'Login Success',
              {
                provider: 'email',
              },
            );
            /* -------- Mixpanel Analytics End -------- */
            /* -------- Slacktivity Alerts -------- */
            window.Slacktivity.send({
              title: 'User Login Success',
              fallback: 'User Login Success',
              'Login Status': 'Success',
              'User Email': email,
              Provider: 'email',
            });
          }
          /* -------- Slacktivity Alerts End -------- */

          authToken.setToken(resp.auth_token);
          $rootScope.$broadcast(authEvents.loginSuccess);
          d.resolve(resp.user);
        }).error((resp) => {
          $rootScope.$broadcast(authEvents.loginFailed);
          d.reject(resp.error);
        });
        return d.promise;
      },
      loginWithToken(auth_token, email, provider) {
        // const d = $q.defer();
        mixpanel.identify(email);
        mixpanel.people.set({
          $email: email,
          jwtToken: auth_token,
        });
        // If on production
        if (API_URI_BASE.indexOf('mightysignal.com') >= 0) {
          mixpanel.track(
            'Login Success',
            {
              provider,
              email,
            },
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          window.Slacktivity.send({
            title: 'User Login Success',
            fallback: 'User Login Success',
            'Login Status': 'Success',
            'User Email': email,
            Provider: provider,
          });
        }
        /* -------- Slacktivity Alerts End -------- */

        authToken.setToken(auth_token);
        $rootScope.$broadcast(authEvents.loginSuccess);
      },
      loginFailed(message, provider, email) {
        mixpanel.track(
          'Login Failed',
          {
            provider,
            message,
            email,
          },
        );
        window.Slacktivity.send({
          title: 'User Login Failed',
          fallback: 'User Login Failed',
          'Login Status': 'Failed',
          color: '#E82020',
          'User Email': email,
          Provider: provider,
        });
      },
      permissions() {
        return $http.get('/auth/permissions');
      },
      userInfo() {
        return $http.get('/auth/user/info');
      },
      accountInfo() {
        return $http.get('/auth/account/info');
      },
      referrer(path) {
        if (path) { ref = path; }
        return ref;
      },
    };
  }])
  .factory('authInterceptor', ['$q', '$injector', function ($q, $injector) {
    return {
      // This will be called on every outgoing http request
      request(config) {
        const authToken = $injector.get('authToken');
        const token = authToken.get();
        config.headers = config.headers || {};
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config || $q.when(config);
      },
      // This will be called on every incoming response that has en error status code
      responseError(response) {
        const authEvents = $injector.get('authEvents');
        const matchesAuthenticatePath = response.config && response.config.url.match(new RegExp('/api/auth'));
        if (!matchesAuthenticatePath) {
          $injector.get('$rootScope').$broadcast({
            401: authEvents.notAuthenticated,
            403: authEvents.notAuthorized,
            409: authEvents.sharedAuthentication,
            418: authEvents.authRevoked,
            419: authEvents.sessionTimeout,
          }[response.status], response);
        }
        return $q.reject(response);
      },
    };
  }]);
