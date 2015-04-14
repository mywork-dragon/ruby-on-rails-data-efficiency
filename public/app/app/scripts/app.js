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
  .run(function () {

      $(document).ready(function(){

        setTimeout(function(){
          $('.page-loading-overlay').addClass("loaded");
          $('.load_circle_wrapper').addClass("loaded");
        },1000);

      });

    })
  .config(function ($routeProvider) {
     $routeProvider
      .when('/', {
        templateUrl: '/views/dashboard.html',
        controller: 'MainCtrl'
      })
       .when('/app/:id', {
         templateUrl: 'views/app-details.html'
       })
       .when('/company/:id', {
         templateUrl: 'views/company-details.html'
       })
      .otherwise({
        redirectTo: '/'
      });
  });

