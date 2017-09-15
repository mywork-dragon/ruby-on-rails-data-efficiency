'use strict';

angular.module('appApp')
  .controller('LoginCtrl', ["$scope", "$location", "authService", "authToken", "listApiService", "$rootScope", "$route", "pageTitleService", "$window", '$auth', '$routeParams',
    function ($scope, $location, authService, authToken, listApiService, $rootScope, $route, pageTitleService, $window, $auth, $routeParams) {

      $scope.pageTitleService = pageTitleService;
      $scope.user = {}
      $scope.redMessage = false

      if ($routeParams.token) {
        $scope.message = "Please link either your Google or LinkedIn account now. You will use that account to login in the future."
        $scope.redMessage = true
      } else if ($routeParams.msg) {
        $scope.message = $routeParams.msg.replace(/<[^>]+>/gm, '')
        $scope.redMessage = true
      } else {
        $scope.message = "Log in using Google or LinkedIn"
      }

      $scope.authenticate = function(provider) {
        $auth.authenticate(provider, {token: $routeParams.token})
        .then(function(response) {
          // Signed in
          authService.loginWithToken(response.data.auth_token, response.data.email)
          $rootScope.connectedOauth = true
          listApiService.getLists().success(function(data) {
            $rootScope.usersLists = data;
          });

          $window.location.href = `#${authService.referrer()}`;
        })
        .catch(function(response) {
          alert(response.data.error)
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
        });
      };

    }]);
