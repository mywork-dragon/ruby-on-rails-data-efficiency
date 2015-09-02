'use strict';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
var API_URI_BASE = "http://" + location.host + "/";
var APP_PLATFORM = "ios";
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

        /* Populates "Categories" dropdown with list of categories */
        $http({
          method: 'GET',
					url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        }).success(function(data) {
          $rootScope.categoryFilterOptions = data;
        });

      });

    })
  .config(['$routeProvider', function ($routeProvider) {
     $routeProvider
       .when('/search', {
         templateUrl: '/app/app/views/dashboard.html',
         activeTab: 'search',
         reloadOnSearch: false
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

