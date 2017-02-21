'use strict';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
var API_URI_BASE = location.protocol + "//" + location.host + "/";
var APP_PLATFORM = "ios"; // Default
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
    "rt.encodeuri",
    'angucomplete-alt',
    'angularjs-dropdown-multiselect',
    'infinite-scroll',
    'satellizer',
    'bootstrapLightbox',
    'isoCurrency',
    'rzModule'
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
        .when('/charts', {
          templateUrl: '/app/app/views/charts.html',
          activeTab: 'charts',
        })
        .when('/charts/top-ios-apps', {
          templateUrl: '/app/app/views/charts/top-ios-apps.html',
          activeTab: 'charts',
          action: 'charts.top-ios-apps'
        })
        .when('/charts/top-android-apps', {
          templateUrl: '/app/app/views/charts/top-android-apps.html',
          activeTab: 'charts',
          action: 'charts.top-android-apps'
        })
        .when('/charts/ios-sdks', {
          templateUrl: '/app/app/views/charts/ios-sdks.html',
          activeTab: 'charts',
          action: 'charts.ios-sdks'
        })
        .when('/charts/android-sdks', {
          templateUrl: '/app/app/views/charts/android-sdks.html',
          activeTab: 'charts',
          action: 'charts.android-sdks'
        })
        .when('/charts/ios-engagement', {
          templateUrl: '/app/app/views/charts/ios-engagement.html',
          activeTab: 'charts',
          action: 'charts.ios-engagement'
        })
        .when('/search/sdk/:platform', {
          templateUrl: '/app/app/views/sdk-search.html',
          activeTab: 'search'
        })
        .when('/timeline', {
          templateUrl: '/app/app/views/newsfeed.html',
          activeTab: 'newsfeed'
        })
        .when('/ad-intelligence', {
          templateUrl: '/app/app/views/ad-intelligence.html',
          activeTab: 'ad-intelligence'
        })
        .when('/admin', {
          templateUrl: '/app/app/views/admin.html',
          activeTab: 'admin'
        })
        .when('/publisher/:platform/:id', {
          templateUrl: '/app/app/views/publisher-details.html',
          activeTab: 'search'
        })
        .when('/search/custom', {
          templateUrl: '/app/app/views/custom-search-results.html',
          activeTab: 'search'
        })
        .when('/app/:platform/:id', {
          templateUrl: '/app/app/views/app-details.html',
          controller: 'AppDetailsCtrl',
          activeTab: 'search'
        })
        .when('/company/:id', {
          templateUrl: '/app/app/views/company-details.html',
          controller: 'CompanyDetailsCtrl',
          activeTab: 'search'
        })
        .when('/lists/:id', {
          templateUrl: '/app/app/views/list.html',
          activeTab: 'lists'
        })
        .when('/sdk/:platform/:id', {
          templateUrl: '/app/app/views/sdk-details.html',
          controller: 'SdkDetailsCtrl as sdkDetailsCtrl',
          activeTab: 'sdks'
        })
        .otherwise({
          redirectTo: '/timeline',
          activeTab: 'newsfeed'
        });
  }])
  .config(['$httpProvider', function($httpProvider) {
     return $httpProvider.interceptors.push("authInterceptor");
  }])
  .config(['$uibTooltipProvider', function($tooltipProvider){
    $tooltipProvider.setTriggers({
      'mouseenter': 'mouseleave click'
    });
  }])
  .config(function($authProvider) {
    $authProvider.linkedin({
      clientId: '755ulzsox4aboj'
    });
    
    $authProvider.google({
      clientId: '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com'
    })
  })
  .filter('capitalize', function() {
    return function(input, all) {
      return (!!input) ? input.replace(/([^\W_]+[^\s-]*) */g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();}) : '';
    }
  })
  .filter('uniqueStrings', function() {
    return function(arr) {
      var newArr = []
      for (var i in arr) {
        if (newArr.indexOf(arr[i]) == -1) {
          newArr.push(arr[i]) 
        }
      }
      return newArr
    }
  });

