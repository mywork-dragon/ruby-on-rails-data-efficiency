import angular from 'angular';
import $ from 'jquery';

/**
 * Main module of the application.
 */

/* Constants */
// var API_URI_BASE = "http://mightysignal.com/";
window.API_URI_BASE = `${window.location.protocol}//${window.location.host}/`;
window.APP_PLATFORM = 'ios'; // Default
window.JWT_TOKEN_NAME = 'ms_jwt_auth_token';
window.MQUERY_SERVICE = 'https://query.ms-static.com';

if (window.location.host === 'localhost:3000') {
  window.JWT_TOKEN_NAME = 'dev_ms_jwt_auth_token';
}

angular
  .module('appApp', [
    'ngRoute',
    'ngSanitize',
    'ngTagsInput',
    'app.directives',
    'ui.bootstrap',
    'rt.encodeuri',
    'angucomplete-alt',
    'angularjs-dropdown-multiselect',
    'infinite-scroll',
    'satellizer',
    'bootstrapLightbox',
    'isoCurrency',
    'rzModule',
    'ui.router',
  ])
  .config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {
    const adIntelligenceState = {
      name: 'ad-intelligence',
      url: '/ad-intelligence',
      template: require('containers/AdIntelligencePage/views/ad-intelligence.html'),
      controller: 'AdIntelligenceController as adIntel',
    };

    const adminState = {
      name: 'admin',
      url: '/admin',
      template: require('containers/AdminPage/views/admin.html'),
      controller: 'AdminController as admin',
    };

    const appAdIntelState = {
      name: 'app.ad-intelligence',
      url: '/ad-intelligence',
      template: require('containers/AppPage/views/ad-intelligence.html'),
    };

    const appInfoState = {
      name: 'app.info',
      url: '',
      template: require('containers/AppPage/views/info.html'),
    };

    const appRankingsState = {
      name: 'app.rankings',
      url: '/rankings',
      template: require('containers/AppPage/views/rankings.html'),
    };

    const appState = {
      name: 'app',
      url: '/app/{platform}/{id}?utm_source',
      abstract: true,
      template: require('containers/AppPage/views/header.html'),
      controller: 'AppController as app',
    };

    const customSearchState = {
      name: 'custom-search',
      url: '/search/custom',
      template: require('containers/CustomSearchPage/views/custom-search-results.html'),
    };

    const exploreState = {
      name: 'explore',
      url: '/search',
      template: require('containers/ExplorePage/views/dashboard.html'),
    };

    const explorev2State = {
      name: 'explore-v2',
      url: '/search/v2',
      template: '<div><explore /><aside><list-create /></aside></div>',
    };

    const explorev2QueryState = {
      name: 'explore-v2-query',
      url: '/search/v2/{queryId}',
      template: '<div><explore /><aside><list-create /></aside></div>',
    };

    const listState = {
      name: 'list',
      url: '/lists/{listId}',
      template: require('../views/list.html'),
    };

    const loginState = {
      name: 'login',
      url: '/login?token&msg',
      template: require('containers/LoginPage/views/signin.html'),
    };

    const newcomerState = {
      name: 'newcomer-apps',
      url: '/popular-apps/newcomers',
      template: require('containers/PopularAppsPage/views/newcomers.html'),
      controller: 'PopularAppsController as popularApps',
      data: {
        type: 'newcomers',
      },
      onExit: ['$rootScope', function ($rootScope) {
        $rootScope.tags = [];
      }],
    };

    const publisherState = {
      name: 'publisher',
      url: '/publisher/{platform}/{id}',
      abstract: true,
      template: require('containers/PublisherPage/views/header.html'),
      controller: 'PublisherController as publisher',
    };

    const publisherAdIntelState = {
      name: 'publisher.ad-intelligence',
      url: '/ad-intelligence',
      template: require('containers/PublisherPage/views/ad-intelligence.html'),
    };

    const publisherInfoState = {
      name: 'publisher.info',
      url: '',
      template: require('containers/PublisherPage/views/info.html'),
    };

    const sdkState = {
      name: 'sdk',
      url: '/sdk/{platform}/{id}',
      template: require('containers/SdkPage/views/sdk-details.html'),
      controller: 'SdkDetailsCtrl as sdkDetailsCtrl',
    };

    const sdkSearchState = {
      name: 'sdk-search',
      url: '/search/sdks?item&numPerPage&page&query',
      template: require('containers/CustomSearchPage/views/sdk-search.html'),
    };

    const timelineState = {
      name: 'timeline',
      url: '/timeline',
      template: require('containers/TimelinePage/views/newsfeed.html'),
    };

    const topAppChartState = {
      name: 'top-app-chart',
      url: '/popular-apps/charts/{platform}/{rankType}/{country}/{category}?page',
      template: require('containers/PopularAppsPage/views/top-app-chart.html'),
      controller: 'TopChartController as topChart',
    };

    const trendingState = {
      name: 'trending-apps',
      url: '/popular-apps/trending',
      template: require('containers/PopularAppsPage/views/trending.html'),
      controller: 'PopularAppsController as popularApps',
      data: {
        type: 'trending',
      },
      onExit: ['$rootScope', function ($rootScope) {
        $rootScope.tags = [];
      }],
    };

    $stateProvider.state(loginState);
    $stateProvider.state(timelineState);
    $stateProvider.state(exploreState);
    $stateProvider.state(explorev2State);
    $stateProvider.state(explorev2QueryState);
    $stateProvider.state(customSearchState);
    $stateProvider.state(trendingState);
    $stateProvider.state(newcomerState);
    $stateProvider.state(topAppChartState);
    $stateProvider.state(adIntelligenceState);
    $stateProvider.state(adminState);
    $stateProvider.state(appState);
    $stateProvider.state(appInfoState);
    $stateProvider.state(appAdIntelState);
    $stateProvider.state(appRankingsState);
    $stateProvider.state(publisherState);
    $stateProvider.state(publisherInfoState);
    $stateProvider.state(publisherAdIntelState);
    $stateProvider.state(sdkSearchState);
    $stateProvider.state(listState);
    $stateProvider.state(sdkState);
    $urlRouterProvider.otherwise('/timeline');
  }])
  .run(['$http', '$rootScope', '$state', '$stateParams', function ($http, $rootScope, $state, $stateParams) {
    $rootScope.$state = $state;
    $rootScope.$stateParams = $stateParams;
    $(document).ready(() => {
      /* Disables loading spinner */
      setTimeout(() => {
        $('.page-loading-overlay').addClass('loaded');
        $('.load_circle_wrapper').addClass('loaded');
      }, 300);
    });
  }])
  .config(['$httpProvider', function ($httpProvider) {
    return $httpProvider.interceptors.push('authInterceptor');
  }])
  .config(['$authProvider', function ($authProvider) {
    $authProvider.linkedin({
      clientId: '755ulzsox4aboj',
    });

    $authProvider.google({
      clientId: '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com',
    });

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
      state: () => encodeURIComponent(Math.random().toString(36).substr(2)),
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
      state: () => encodeURIComponent(Math.random().toString(36).substr(2)),
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
      state: () => encodeURIComponent(Math.random().toString(36).substr(2)),
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
      state: () => encodeURIComponent(Math.random().toString(36).substr(2)),
    });
  }])
  .filter('capitalize', () => input => ((angular.isString(input) && input.length > 0) ? input[0].toUpperCase() + input.substr(1).toLowerCase() : input))
  .filter('uniqueStrings', () => (arr) => {
    const newArr = [];
    for (const i in arr) {
      if (newArr.indexOf(arr[i]) === -1) {
        newArr.push(arr[i]);
      }
    }
    return newArr;
  });
