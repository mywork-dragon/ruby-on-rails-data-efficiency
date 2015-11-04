'use strict';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
var API_URI_BASE = "http://" + location.host + "/";
var APP_PLATFORM = "android"; // Default
var JWT_TOKEN_NAME = "ms_jwt_auth_token";

if (location.host == "localhost:3000") {
  JWT_TOKEN_NAME = "dev_ms_jwt_auth_token";
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
        },300);

      });

    })
  .config(['$routeProvider', function ($routeProvider) {
     $routeProvider
       .when('/login', {
         templateUrl: '/app/app/views/signin.html'
       })
       .when('/search', {
         templateUrl: '/app/app/views/dashboard.html',
         activeTab: 'search',
         reloadOnSearch: false
       })
       .when('/search/sdk', {
         templateUrl: '/app/app/views/sdk-search.html',
         activeTab: 'sdks'
       })
       .when('/search/custom', {
         templateUrl: '/app/app/views/custom-search-results.html',
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
         activeTab: 'lists'
       })
       .otherwise({
         redirectTo: '/search',
         activeTab: 'search'
       });
  }])
  .config(['$httpProvider', function($httpProvider) {
     return $httpProvider.interceptors.push("authInterceptor");
  }])
  .filter('capitalize', function() {
    return function(input, all) {
      return (!!input) ? input.replace(/([^\W_]+[^\s-]*) */g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();}) : '';
    }
  });

