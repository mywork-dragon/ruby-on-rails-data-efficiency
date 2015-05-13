'use strict';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
var API_URI_BASE = "http://" + location.host + "/";
var APP_PLATFORM = "ios";

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
  .run(function ($http, $rootScope, $auth, apiService) {

      $(document).ready(function(){

        /* Disables loading spinner */
        setTimeout(function(){
          $('.page-loading-overlay').addClass("loaded");
          $('#app > .load_circle_wrapper').addClass("loaded");
        },1000);

        /* Populates "Categories" dropdown with list of categories */
        $http({
          method: 'GET',
					url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        }).success(function(data) {
          console.log(APP_PLATFORM);
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
      .otherwise({
        redirectTo: '/'
      });
  })
  .config(function($authProvider) {
    $authProvider.configure({
      apiUrl: '/auth',
      tokenValidationPath: '/validate_token',
      emailSignInPath: '/login'
    });
  });

