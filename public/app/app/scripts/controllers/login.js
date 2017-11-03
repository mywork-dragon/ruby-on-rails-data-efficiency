'use strict';

angular.module('appApp')
  .controller('LoginCtrl', ["$scope", "$location", "authService", "authToken", "listApiService", "$rootScope", "pageTitleService", "$window", '$auth', '$stateParams',
    function ($scope, $location, authService, authToken, listApiService, $rootScope, pageTitleService, $window, $auth, $stateParams) {

      $scope.pageTitleService = pageTitleService;
      $scope.user = {}
      $scope.token = $stateParams.token
      $scope.redMessage = false

      if ($scope.token) {
        $scope.message = "Please link either your Google or LinkedIn account now. You will use that account to login in the future."
        $scope.redMessage = true
      } else if ($stateParams.msg) {
        $scope.message = $stateParams.msg.replace(/<[^>]+>/gm, '')
        $scope.redMessage = true
      } else {
        $scope.message = "Log in using Google or LinkedIn"
      }

      $scope.authenticate = function(provider) {

        $auth.authenticate(provider, {token: $scope.token})
        .then(function(response) {
          // Signed in
          authService.loginWithToken(response.data.auth_token, response.data.email, provider)
          $rootScope.connectedOauth = true
          listApiService.getLists().success(function(data) {
            $rootScope.usersLists = data;
          });

          $window.location.href = `#${authService.referrer()}`;
        })
        .catch(function(response) {
          alert(response.data.error)
          authService.loginFailed(response.data.error, provider, response.data.email)
        });
      };

      /* Login specific logic */
      $scope.onLoginButtonClick = function() {
        authService.login($scope.user.email, $scope.user.password).then(function(){
          // $rootScope.isAuthenticated = authToken.isAuthenticated();
          listApiService.getLists().success(function(data) {
            $rootScope.usersLists = data;
          });
          $window.location.href = "#/timeline";
        },
        function(data){
          alert(data);
          authService.loginFailed(data, 'email', $scope.user.email)
        });
      };

    }]);
