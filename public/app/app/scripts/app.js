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
    'rzModule',
    'ui.router'
  ])
  .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    var adIntelligenceState = {
      name: 'ad-intelligence',
      url: '/ad-intelligence',
      templateUrl: '/app/app/ad-intelligence/views/ad-intelligence.html',
      controller: 'AdIntelligenceController as adIntel'
    }

    var adminState  = {
      name: 'admin',
      url: '/admin',
      templateUrl: '/app/app/views/admin.html'
    }

    var androidSdksState = {
      name: 'charts.android-sdks',
      url: '/android-sdks',
      templateUrl: '/app/app/views/charts/android-sdks.html'
    }

    var appAdIntelState = {
      name: 'app.ad-intelligence',
      url: '/ad-intelligence',
      templateUrl: '/app/app/apps/views/ad-intelligence.html'
    }

    var appInfoState = {
      name: 'app.info',
      url: '',
      templateUrl: '/app/app/apps/views/info.html'
    }

    var appState = {
      name: 'app',
      url: '/app/{platform}/{id}?utm_source',
      abstract: true,
      templateUrl: '/app/app/apps/views/header.html',
      controller: 'AppController as app'
    }

    var chartsState = {
      name: 'charts',
      url: '/charts',
      templateUrl: '/app/app/views/charts/charts.html'
    }

    var customSearchState = {
      name: 'custom-search',
      url: '/search/custom',
      templateUrl: '/app/app/views/custom-search-results.html'
    }

    var exploreState = {
      name: 'explore',
      url: '/search',
      templateUrl: '/app/app/views/dashboard.html'
    }

    var iosEngagementState = {
      name: 'charts.ios-engagement',
      url: '/ios-engagement',
      templateUrl: '/app/app/views/charts/ios-engagement.html'
    }

    var iosSdksState = {
      name: 'charts.ios-sdks',
      url: '/ios-sdks',
      templateUrl: '/app/app/views/charts/ios-sdks.html'
    }

    var listState = {
      name: 'list',
      url: '/lists/{id}',
      templateUrl: '/app/app/views/list.html'
    }

    var loginState = {
      name: 'login',
      url: '/login?token&msg',
      templateUrl: '/app/app/views/signin.html'
    }

    var publisherState = {
      name: 'publisher',
      url: '/publisher/{platform}/{id}',
      abstract: true,
      templateUrl: '/app/app/publishers/views/header.html',
      controller: 'PublisherController as publisher'
    }

    var publisherAdIntelState = {
      name: 'publisher.ad-intelligence',
      url: '/ad-intelligence',
      templateUrl: '/app/app/publishers/views/ad-intelligence.html'
    }

    var publisherInfoState = {
      name: 'publisher.info',
      url: '',
      templateUrl: '/app/app/publishers/views/info.html'
    }

    var sdkState = {
      name: 'sdk',
      url: '/sdk/{platform}/{id}',
      templateUrl: '/app/app/views/sdk-details.html',
      controller: 'SdkDetailsCtrl as sdkDetailsCtrl'
    }

    var sdkSearchState = {
      name: 'sdk-search',
      url: '/search/sdk/{platform}?query',
      templateUrl: '/app/app/views/sdk-search.html'
    }

    var singleAdminState = {
      name: 'single-admin',
      url: '/admin/:id',
      templateUrl: '/app/app/views/admin.html'
    }

    var timelineState = {
      name: 'timeline',
      url: '/timeline',
      templateUrl: '/app/app/views/newsfeed.html'
    }

    var topAndroidAppsState = {
      name: 'charts.top-android-apps',
      url: '/top-android-apps',
      templateUrl: '/app/app/views/charts/top-android-apps.html'
    }

    var topIosAppsState = {
      name: 'charts.top-ios-apps',
      url: '/top-ios-apps',
      templateUrl: '/app/app/views/charts/top-ios-apps.html'
    }

    $stateProvider.state(loginState)
    $stateProvider.state(timelineState)
    $stateProvider.state(exploreState)
    $stateProvider.state(customSearchState)
    $stateProvider.state(chartsState)
    $stateProvider.state(topIosAppsState)
    $stateProvider.state(topAndroidAppsState)
    $stateProvider.state(iosSdksState)
    $stateProvider.state(androidSdksState)
    $stateProvider.state(iosEngagementState)
    $stateProvider.state(adIntelligenceState)
    $stateProvider.state(adminState)
    $stateProvider.state(singleAdminState)
    $stateProvider.state(appState)
    $stateProvider.state(appInfoState)
    // $stateProvider.state(appAdIntelState)
    $stateProvider.state(publisherState)
    $stateProvider.state(publisherInfoState)
    // $stateProvider.state(publisherAdIntelState)
    $stateProvider.state(sdkSearchState)
    $stateProvider.state(listState)
    $stateProvider.state(sdkState)
    $urlRouterProvider.otherwise('/timeline')
  }])
  .run(function ($http, $rootScope) {
    $(document).ready(function(){
      /* Disables loading spinner */
      setTimeout(function(){
        $('.page-loading-overlay').addClass("loaded");
        $('#app > .load_circle_wrapper').addClass("loaded");
      },300);
    });
  })
  .config(['$httpProvider', function($httpProvider) {
     return $httpProvider.interceptors.push("authInterceptor");
  }])
  .config(function($authProvider) {
    $authProvider.linkedin({
      clientId: '755ulzsox4aboj'
    });

    $authProvider.google({
      clientId: '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com'
    })

    $authProvider.oauth2({
      name: 'salesforce',
      url: '/auth/salesforce',
      clientId: '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9',
      authorizationEndpoint: 'https://login.salesforce.com/services/oauth2/authorize',
      redirectUri: window.location.origin,
      optionalUrlParams: ['state'],
      requiredUrlParams: ['scope'],
      scope: ['api', 'refresh_token'],
      scopeDelimiter: '%20',
      oauthType: '2.0',
      popupOptions: { width: 500, height: 530 },
      state: () => encodeURIComponent(Math.random().toString(36).substr(2))
    });

    $authProvider.oauth2({
      name: 'salesforce_user',
      url: '/auth/salesforce_user',
      clientId: '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9',
      authorizationEndpoint: 'https://login.salesforce.com/services/oauth2/authorize',
      redirectUri: window.location.origin,
      optionalUrlParams: ['state'],
      requiredUrlParams: ['scope'],
      scope: ['id'],
      scopeDelimiter: '%20',
      oauthType: '2.0',
      popupOptions: { width: 500, height: 530 },
      state: () => encodeURIComponent(Math.random().toString(36).substr(2))
    });

    $authProvider.oauth2({
      name: 'salesforce_sandbox',
      url: '/auth/salesforce_sandbox',
      clientId: '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9',
      authorizationEndpoint: 'https://test.salesforce.com/services/oauth2/authorize',
      redirectUri: window.location.origin,
      optionalUrlParams: ['state'],
      requiredUrlParams: ['scope'],
      scope: ['api', 'refresh_token'],
      scopeDelimiter: '%20',
      oauthType: '2.0',
      popupOptions: { width: 500, height: 530 },
      state: () => encodeURIComponent(Math.random().toString(36).substr(2))
    });

    $authProvider.oauth2({
      name: 'salesforce_user_sandbox',
      url: '/auth/salesforce_user_sandbox',
      clientId: '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9',
      authorizationEndpoint: 'https://test.salesforce.com/services/oauth2/authorize',
      redirectUri: window.location.origin,
      optionalUrlParams: ['state'],
      requiredUrlParams: ['scope'],
      scope: ['id'],
      scopeDelimiter: '%20',
      oauthType: '2.0',
      popupOptions: { width: 500, height: 530 },
      state: () => encodeURIComponent(Math.random().toString(36).substr(2))
    });
  })
  .filter('capitalize', function() {
    return function(input) {
      return (angular.isString(input) && input.length > 0) ? input[0].toUpperCase() + input.substr(1).toLowerCase() : input;
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
