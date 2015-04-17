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
    "ui.bootstrap"
  ])
  .run(function ($http, $rootScope) {

      $(document).ready(function(){

        setTimeout(function(){
          $('.page-loading-overlay').addClass("loaded");
          $('.load_circle_wrapper').addClass("loaded");
        },1000);

        $http({
          method: 'GET',
          url: 'http://mightysignal.com/api/get_ios_categories'
        }).success(function(data) {
          console.log(data);
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
         templateUrl: '/app/app/views/app-details.html'
       })
       .when('/company/:id', {
         templateUrl: '/app/app/views/company-details.html'
       })
      .otherwise({
        redirectTo: '/'
      });
  });

