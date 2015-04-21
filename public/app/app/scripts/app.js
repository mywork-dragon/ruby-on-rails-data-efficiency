'use strict';

/**
 * Main module of the application.
 */

angular
  .module('appApp', [
    'ngRoute',
    'ngSanitize',
    'ngTagsInput',
    'app.directives',
    "ui.bootstrap",
    "rt.encodeuri",
    'ng-token-auth'
  ])
  .run(function ($http, $rootScope) {

      $(document).ready(function(){

        setTimeout(function(){
          $('.page-loading-overlay').addClass("loaded");
          $('.load_circle_wrapper').addClass("loaded");
        },1000);

        $http({
          method: 'GET',
          url: 'http://localhost:3000/api/get_ios_categories'
					// url: 'http://mightysignal.com/api/get_ios_categories'
        }).success(function(data) {
          $rootScope.categoryFilterOptions = data;
        });

      });

    })
  .config(function ($routeProvider) {
     $routeProvider
       .when('/', {
         templateUrl: '/app/app/views/dashboard.html',
         controller: 'MainCtrl'
       })
       .when('/app/:id', {
         templateUrl: '/app/app/views/app-details.html',
         controller: 'AppDetailsCtrl'
       })
       .when('/company/:id', {
         templateUrl: '/app/app/views/company-details.html',
         controller: 'CompanyDetailsCtrl'
       })
       .when('/login', {
         templateUrl: '/app/app/views/signin.html'
       })
      .otherwise({
        redirectTo: '/'
      });
  })
  .config(function($authProvider) {
    $authProvider.configure({
      apiUrl: '/auth',
      tokenValidationPath: '/auth/validate_token',
      signOutUrl: '/auth/sign_out',
      emailSignInPath: '/auth/sign_in',
    });
  });

