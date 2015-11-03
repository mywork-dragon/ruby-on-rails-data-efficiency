'use strict';

angular.module('appApp')
  .controller('LoginCtrl', ["$scope", "$location", "authService", "authToken", "listApiService", "$rootScope", "$route", "pageTitleService", "$window",
    function ($scope, $location, authService, authToken, listApiService, $rootScope, $route, pageTitleService, $window) {

      $scope.pageTitleService = pageTitleService;

      $scope.checkIfOwnPage = function() {
        return _.contains(["/login", "/signin"], $location.path());
      };

      /* Login specific logic */
      $scope.onLoginButtonClick = function() {
        authService.login($scope.userEmail, $scope.userPassword).then(function(){
            // $rootScope.isAuthenticated = authToken.isAuthenticated();
            listApiService.getLists().success(function(data) {
              $rootScope.usersLists = data;
            });
            $window.location.href = "#/search";
          },
          function(){
            alert('Incorrect Email or Password');
          });
      };

    }]);
