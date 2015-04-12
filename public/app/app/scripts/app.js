'use strict';

/**
 * Main module of the application.
 */

angular
  .module('appApp', [
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch'
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
        templateUrl: 'views/dashboard.html',
      })
      .otherwise({
        redirectTo: '/'
      });
  });
