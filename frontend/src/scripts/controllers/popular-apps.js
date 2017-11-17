import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import '../../components/list-create/list-create.directive'; // gross
import '../../components/list-delete/list-delete.directive'; // gross
import '../../components/list-delete-selected/list-delete-selected.directive'; // gross
import '../../components/export-permissions/export-permissions.directive'; // gross

(function() {
  'use strict';

  angular
    .module('appApp')
    .controller('PopularAppsController', PopularAppsController);

  PopularAppsController.$inject = [
    '$scope',
    'popularAppsService',
    '$timeout',
    'listApiService',
    "$location",
    "authToken",
    "$rootScope",
    "$http",
    "$window",
    "apiService",
    "authService",
    'slacktivity',
    "filterService",
    "$uibModal",
    "loggitService",
    "pageTitleService",
    '$stateParams',
    "$q",
    '$state',
    'sdkLiveScanService'
  ];

  function PopularAppsController (
    $scope,
    popularAppsService,
    $timeout,
    listApiService,
    $location,
    authToken,
    $rootScope,
    $http,
    $window,
    apiService,
    authService,
    slacktivity,
    filterService,
    $uibModal,
    loggitService,
    pageTitleService,
    $stateParams,
    $q,
    $state,
    sdkLiveScanService
  ) {

    var popularApps = this;
    popularApps.platform =  'all'
    popularApps.currentPage = 1
    $rootScope.currentPage = 1
    popularApps.numPerPage = 50
    popularApps.isLoading = true
    popularApps.error = false
    popularApps.chartSettings = {
      buttonClasses: '',
      externalIdProp: '',
      dynamicTitle: false
    }
    popularApps.chartCustomText = {
      buttonDefaultText: 'CHART'
    }
    popularApps.chartModel = []
    popularApps.categoryModel = {}
    popularApps.countryModel = {}
    popularApps.countrySelectLoaded = false
    popularApps.categorySelectLoaded = false
    popularApps.sortBy = 'weekly_change'
    popularApps.orderBy = 'desc'
    // functions
    popularApps.sortApps = sortApps;
    popularApps.pageChanged = pageChanged;
    popularApps.submitFilters = submitFilters;
    popularApps.clearFilters = clearFilters;
    popularApps.togglePlatform = togglePlatform;
    popularApps.isActiveSort = isActiveSort; 
    popularApps.linkToChart = linkToChart; 
    popularApps.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    popularApps.trackFilterQuery = trackFilterQuery
    popularApps.trackAppClick = trackAppClick
    popularApps.trackPublisherClick = trackPublisherClick
    popularApps.trackChartClick = trackChartClick
    popularApps.trackSortingClick = trackSortingClick
    $scope.$watch('popularApps.countrySelectLoaded', selectChanged);
    $scope.$watch('popularApps.categorySelectLoaded', selectChanged);
  
    activate()

    function activate() {
      setTitle()
      $rootScope.tags = []
    }

    function getPopularApps(sortBy, orderBy) {
      var params = convertTagsToParams();
    
      popularApps.isLoading = true

      trackFilterQuery()

      if (popularAppType() == 'newcomers') {
        return popularAppsService.getNewcomers(params)
          .then(handleSuccess)
          .catch(handleError)
      } else {
        return popularAppsService.getTrending(params)
          .then(handleSuccess)
          .catch(handleError)
      }
    }

    function handleSuccess(data) {
      popularApps.isLoading = false
      popularApps.apps = data.apps;
      popularApps.numApps = data.total;
      $rootScope.numApps = data.total;
      $rootScope.numPerPage = popularApps.numPerPage
      enrichApps()
    }

    function handleError(response) {
      popularApps.isLoading = false
      popularApps.error = true
    }

    function setTitle() {
      if (popularAppType() == 'newcomers') {
        pageTitleService.setTitle("MightySignal - Newcomer Apps")
      } else {
        pageTitleService.setTitle("MightySignal - Trending Apps")
      }
    }

    function popularAppType() {
      return $state.current.data.type
    }

    function sortApps(sortBy, orderBy) {
      popularApps.sortBy = sortBy
      popularApps.orderBy = orderBy
      trackSortingClick(sortBy, orderBy)
      getPopularApps()
    }

    function pageChanged() {
      $rootScope.currentPage = popularApps.currentPage
      getPopularApps()
    }

    function submitFilters() {
      popularApps.currentPage = 1
      $rootScope.currentPage = 1
      getPopularApps()
    }

    function clearFilters() {
      $rootScope.tags = []
      popularApps.categoryModel = {}
      popularApps.countryModel = {}
    }

    function togglePlatform(platform) {
      popularApps.platform = platform;
      getPopularApps()
    }

    function convertTagsToParams() {
      var params = {'countries[]': [], 'platforms[]': [], 'categories[]': [], 'rank_types[]': []}
      $rootScope.tags = $rootScope.tags || []
      $rootScope.tags.forEach(function(tag) {
        switch(tag.parameter) {
          case 'categories':
            params['categories[]'].push(tag.value)
            break;
          case 'countries':
            params['countries[]'].push(tag.value)
            break;
          case 'charts':
            params['rank_types[]'].push(tag.value)
            break;
          case 'maxRank':
            params['max_rank'] = tag.value
            break;
        }
      })

      switch(popularApps.platform) {
        case 'all':
          params['platforms[]'] = ['ios', 'android']
          break;
        default:
          params['platforms[]'].push(popularApps.platform)
          break;
      }

      params.page = popularApps.currentPage
      params.per_page = popularApps.numPerPage
      params.sortBy = popularApps.sortBy
      params.orderBy = popularApps.orderBy

      return params;
    }

    function isActiveSort(sortBy, orderBy) {
      return popularApps.orderBy == orderBy && popularApps.sortBy == sortBy
    }

    function enrichApps() {
      for (var app of popularApps.apps) {
        app.trending['weekly_change_color'] = popularAppsService.rankChangeColor(app.trending['weekly_change'])
        app.trending['monthly_change_color'] = popularAppsService.rankChangeColor(app.trending['monthly_change'])
        app.trending['rank_color'] = popularAppsService.rankColor(app.trending['rank'])
      }
    }

    function linkToChart(app) {
      return "#/popular-apps/charts/" + app.platform + 
             "/" + app.trending.ranking_type + "/" + 
             app.trending.country + "/" + app.trending.category + 
             "?page=" + Math.ceil(app.trending.rank / popularApps.numPerPage)
    }

    function selectChanged(newVal, oldVal) {
      if (popularApps.countrySelectLoaded && popularApps.categorySelectLoaded) {
        getPopularApps()
      }
    }

    function trackFilterQuery() {
      mixpanel.track("Filtered Popular Apps", mixpanelQueryData())
    }

    function trackAppClick(app) {
      mixpanel.track("Clicked App on Popular Apps", Object.assign({}, mixpanelAppData(app), mixpanelQueryData()))
    }

    function trackPublisherClick(app) {
      mixpanel.track("Clicked Publisher on Popular Apps", Object.assign({}, mixpanelAppData(app), mixpanelQueryData()))
    }

    function trackChartClick(app) {
      mixpanel.track("Clicked Chart on Popular Apps", Object.assign({}, mixpanelAppData(app), mixpanelQueryData()))
    }

    function trackSortingClick(sort, order) {
      mixpanel.track("Sorted Popular Apps", Object.assign({'sort': sort, 'order': order}, mixpanelQueryData()))
    }

    function mixpanelAppData(app) {
      return {
        'platform': app.platform,
        'rank': app.trending.rank,
        'app_id': app.id,
        'app_name': app.name,
        'publisher_id': app.publisher.id,
        'publisher_name': app.publisher.name,
        'weekly_change': app.trending.weekly_change,
        'monthly_change': app.trending.monthly_change,
        'app_category': app.trending.category,
        'app_ranking_type': app.trending.ranking_type,
        'app_country': app.trending.country
      }
    }

    function mixpanelQueryData() {
      return {
        'type': popularAppType(),
        'platform': popularApps.platform,
        'max_rank': popularApps.maxRank,
        'charts': popularApps.chartModel,
        'page': popularApps.currentPage,
        'categories': Object.keys(popularApps.categoryModel).filter(category => popularApps.categoryModel[category]),
        'countries"': Object.keys(popularApps.countryModel).filter(country => popularApps.countryModel[country]),
      }
    }
  }
})();
