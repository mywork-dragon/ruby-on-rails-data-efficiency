import angular from 'angular';

angular.module('appApp')
  .controller('LoginCtrl', ['$scope', '$location', 'authService', 'authToken', 'listApiService', '$rootScope', 'pageTitleService', '$window', '$auth', '$stateParams',
    function ($scope, $location, authService, authToken, listApiService, $rootScope, pageTitleService, $window, $auth, $stateParams) {
      $scope.pageTitleService = pageTitleService;
      $scope.user = {};
      $scope.token = $stateParams.token;
      $scope.redMessage = false;
      $scope.showEmailLogin = false;

      $scope.toggleEmailLogin = function() {
        $scope.showEmailLogin = !$scope.showEmailLogin;
        if ($scope.showEmailLogin) {
          $scope.message = 'Log in with email and password';
        } else {
          $scope.message = 'Log in using Google or LinkedIn';
        }
      };

      if ($scope.token) {
        $scope.message = 'Please link either your Google or LinkedIn account now. You will use that account to login in the future.';
        $scope.redMessage = true;
      } else if ($stateParams.msg) {
        $scope.message = $stateParams.msg.replace(/<[^>]+>/gm, '');
        $scope.redMessage = true;
      } else {
        $scope.message = 'Log in using Google or LinkedIn';
      }

      $scope.authenticate = function(provider) {
        $auth.authenticate(provider, { token: $scope.token })
          .then((response) => {
          // Signed in
            authService.loginWithToken(response.data.auth_token, response.data.email, provider);
            $rootScope.connectedOauth = true;
            listApiService.getLists().success((data) => {
              $rootScope.usersLists = data;
            });

            $window.location.href = `#${authService.referrer()}`;
          })
          .catch((response) => {
            alert(response.data.error);
            authService.loginFailed(response.data.error, provider, response.data.email);
          });
      };

      /* Login specific logic */
      $scope.onLoginButtonClick = function() {
        authService.login($scope.user.email, $scope.user.password).then(
          () => {
            $rootScope.isAuthenticated = authToken.isAuthenticated();
            listApiService.getLists().success((data) => {
              $rootScope.usersLists = data;
            });
            $window.location.href = '#/timeline';
          },
          (data) => {
            alert(data);
            authService.loginFailed(data, 'email', $scope.user.email);
          },
        );
      };
    }]);
