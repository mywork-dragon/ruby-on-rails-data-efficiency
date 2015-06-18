'use strict';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
var API_URI_BASE = "http://" + location.host + "/";
var APP_PLATFORM = "ios";
var JWT_TOKEN_NAME = "jwt_auth_token";

if (location.host == "localhost:3000") {
  JWT_TOKEN_NAME = "dev_jwt_auth_token";
}

angular
  .module('appApp', [
    'ngRoute',
    'ngSanitize',
    'ngTagsInput',
    'app.directives',
    "ui.bootstrap",
    "rt.encodeuri"
  ])
  .run(function ($http, $rootScope) {

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
          $rootScope.categoryFilterOptions = data;
        });

      });

    })
  .config(function ($routeProvider) {
     $routeProvider
       .when('/', {
         templateUrl: '/app/app/views/dashboard.html',
         controller: 'MainCtrl',
         activeTab: 'search'
       })
       .when('/app/:platform/:id', {
         templateUrl: '/app/app/views/app-details.html',
         controller: 'AppDetailsCtrl'
       })
       .when('/company/:id', {
         templateUrl: '/app/app/views/company-details.html',
         controller: 'CompanyDetailsCtrl'
       })
       .when('/lists/:id', {
         templateUrl: '/app/app/views/list.html',
         controller: 'ListCtrl',
         activeTab: 'lists'
       })
      .otherwise({
        redirectTo: '/',
         activeTab: 'search'
      });
  })
  .config(function($httpProvider) {
    return $httpProvider.interceptors.push("authInterceptor");
  })
  .filter('capitalize', function() {
    return function(input, all) {
      return (!!input) ? input.replace(/([^\W_]+[^\s-]*) */g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();}) : '';
    }
  });

