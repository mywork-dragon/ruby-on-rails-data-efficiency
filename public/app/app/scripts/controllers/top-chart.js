(function() {
  'use strict';

  angular
    .module('appApp')
    .controller('TopChartController', TopChartController);

  TopChartController.$inject = [
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

  function TopChartController (
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

    var topChart = this;
    topChart.numPerPage = 50
    topChart.isLoading = true
    
    topChart.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo;
    topChart.pageChanged = pageChanged
    topChart.changedCountry = changedCountry
    topChart.changedCategory = changedCategory
    topChart.togglePlatform = togglePlatform
    topChart.toggleRankType = toggleRankType
    topChart.trackAppClick = trackAppClick
    topChart.trackPublisherClick = trackPublisherClick
  
    activate()

    function activate() {
      if ($stateParams.page) {
        topChart.numApps = 10000
        topChart.currentPage = $stateParams.page
      } else {
        topChart.currentPage = 1
      }

      setTitle()
      getCountries()
      .then(getIosCategories)
      .then(getAndroidCategories)
      .then(function() {
        topChart.rankType = $stateParams.rankType
        topChart.platform = $stateParams.platform

        topChart.country = countryCollection().find(function(country) {
          return country.id == $stateParams.country
        })

        topChart.category = categoryCollection().find(function(category) {
          return category.id == $stateParams.category
        })
        
        getTopChart()
      })
    }

    function getTopChart() {
          
      topChart.isLoading = true
      trackQuery(queryParams())

      return popularAppsService.getChart(queryParams())
        .then(function(data) {
          topChart.isLoading = false
          topChart.apps = data.apps;
          topChart.numApps = data.total;
        })
        .catch(function(response) {
          topChart.isLoading = false
          topChart.error = true
        })
    }

    function setTitle() {
      pageTitleService.setTitle("MightySignal - Top Apps Chart")
    }

    function getCountries() {
      return apiService.getCountries()
      .then(function(data) {
        data = data.sort((a, b) => a.name.localeCompare(b.name))
        topChart.iosCountries = data.filter(country => country.platforms.includes('ios'))
        topChart.androidCountries = data.filter(country => country.platforms.includes('android'))
      })
    }

    function getIosCategories() {
      return apiService.getIosCategories()
      .then(function(data) {
        data = data.sort((a, b) => a.name.localeCompare(b.name))
        topChart.iosCategories = data
      })
    }

    function getAndroidCategories() {
      return apiService.getAndroidCategories()
      .then(function(data) {
        data = data.sort((a, b) => a.name.localeCompare(b.name))
        topChart.androidCategories = data
      })
    }

    function pageChanged() {
      getTopChart()
    }

    function togglePlatform(platform) {
      topChart.platform = platform
      topChart.currentPage = 1

      topChart.category = defaultCategory()

      topChart.country = countryCollection().find(function(country) {
        return country.platforms.includes(platform) && country.id == topChart.country.id
      })

      topChart.country = topChart.country || defaultCountry()
      
      getTopChart()
    }

    function toggleRankType(type) {
      topChart.rankType = type
      topChart.currentPage = 1
      getTopChart()
    }

    function changedCountry() {
      topChart.currentPage = 1
      getTopChart()
    }

    function changedCategory() {
      topChart.currentPage = 1
      getTopChart()
    }

    function countryCollection() {
      var countries = topChart.iosCountries
      if (topChart.platform == 'android') {
        countries = topChart.androidCountries
      } 
      return countries
    }

    function categoryCollection() {
      var categories = topChart.iosCategories
      if (topChart.platform == 'android') {
        categories = topChart.androidCategories
      } 
      return categories
    }

    function defaultCategory() {
      if (topChart.platform == 'ios') {
        return {id: '36', name: 'Overall'}
      } else {
        return {id: 'OVERALL', name: 'Overall'}
      }
    }

    function defaultCountry() {
      return {id: 'US', name: 'United States'}
    }

    function queryParams() {
      return {
        page_num: topChart.currentPage,
        size: topChart.numPerPage,
        rank_type: topChart.rankType,
        country: topChart.country ? topChart.country.id : $stateParams.country,
        platform: topChart.platform,
        category: topChart.category ? topChart.category.id : $stateParams.category,
      }
    }

    function trackQuery() {
      mixpanel.track("Viewed Top Apps Chart", queryParams())
    }

    function trackAppClick(app) {
      mixpanel.track("Clicked App on Popular Apps", Object.assign({}, mixpanelAppData(app), queryParams()))
    }

    function trackPublisherClick(app) {
      mixpanel.track("Clicked Publisher on Popular Apps", Object.assign({}, mixpanelAppData(app), queryParams()))
    }

    function mixpanelAppData(app) {
      return {
        'platform': app.platform,
        'rank': app.trending.rank,
        'app_id': app.id,
        'app_name': app.name,
        'publisher_id': app.publisher.id,
        'publisher_name': app.publisher.name,
        'app_category': app.trending.category,
        'app_ranking_type': app.trending.ranking_type,
        'app_country': app.trending.country
      }
    }

  }
})();
