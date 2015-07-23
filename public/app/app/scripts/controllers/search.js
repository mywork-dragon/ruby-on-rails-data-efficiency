'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", "$location", "authToken", "$rootScope", "$http", "$window", "searchService",
    function ($scope, $location, authToken, $rootScope, $http, $window, searchService) {

      var searchCtrl = this; // same as searchCtrl = $scope

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function() {

        var urlParams = $location.url().split('/search')[1]; // If url params not provided
        var routeParams = $location.search();

        console.log('routeParams.custom', routeParams.custom, routeParams.custom);

        /* Complile Object with All Filters from Params */
        if (routeParams.app) var appParams = JSON.parse(routeParams.app);
        if (routeParams.company) var companyParams = JSON.parse(routeParams.company);
        if (routeParams.custom) var customParams = JSON.parse(routeParams.custom);
        var allParams = appParams ? appParams : [];
        if (routeParams.custom && customParams['customKeywords'] && customParams['customKeywords'][0]) allParams['customKeywords'] = customParams['customKeywords'];
        console.log('CUSTOM PARAMS:', customParams, customParams[0]);
        for (var attribute in companyParams) { allParams[attribute] = companyParams[attribute]; }

        $rootScope.tags = [];

        /* Rebuild Filters Array from URL Params */
        for (var key in allParams) {

          var value = allParams[key];

          if(Array.isArray(value)) {
            value.forEach(function(arrayItem) {
              if (arrayItem) $rootScope.tags.push(searchService.searchFilters(key, arrayItem));
            });
          } else {
            $rootScope.tags.push(searchService.searchFilters(key, value));
          }
        }

        var submitSearchStartTime = new Date().getTime();
        $scope.queryInProgress = true;
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/filter_' + APP_PLATFORM + '_apps' + urlParams
        })
          .success(function(data) {
            searchCtrl.apps = data.results;
            searchCtrl.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            searchCtrl.currentPage = 1;
            searchCtrl.resultsSortCategory = 'appName';
            searchCtrl.resultsOrderBy = 'ASC';

            var submitSearchEndTime = new Date().getTime();
            var submitSearchElapsedTime = submitSearchEndTime - submitSearchStartTime;

            /* -------- Mixpanel Analytics Start -------- */
            var searchQueryPairs = {};
            var searchQueryFields = [];
            $rootScope.tags.forEach(function(tag) {
              searchQueryPairs[tag.parameter] = tag.value;
              searchQueryFields.push(tag.parameter);
            });
            searchQueryPairs['tags'] = searchQueryFields;
            searchQueryPairs['numOfApps'] = data.resultsCount;
            searchQueryPairs['elapsedTimeInMS'] = submitSearchElapsedTime;
            searchQueryPairs['platform']  = APP_PLATFORM;
            mixpanel.track(
              "Search Request Successful",
              searchQueryPairs
            );
            /* -------- Mixpanel Analytics End -------- */
          })
          .error(function(data, status) {
            $rootScope.dashboardSearchButtonDisabled = false;
            mixpanel.track(
              "Search Request Failed",
              {
                "tags": $rootScope.tags,
                "errorMessage": data,
                "errorStatus": status,
                "platform": APP_PLATFORM
              }
            );
          });

      };

      /* Only hit api if query string params are present */
      if($location.url().split('/search')[1]) {
        searchCtrl.loadTableData();
      }

      // When main Dashboard search button is clicked
      searchCtrl.submitSearch = function() {
        var urlParams = searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy);
        $location.url('/search?' + urlParams);
        searchCtrl.loadTableData();
      };

      searchCtrl.appsDisplayedCount = function() {
        var lastPageMaxApps = $rootScope.numPerPage * searchCtrl.currentPage;
        var baseAppNum = $rootScope.numPerPage * (searchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > searchCtrl.numApps) {
          return "" + baseAppNum + " - " + searchCtrl.numApps;
        } else {
          return "" + baseAppNum + " - " + lastPageMaxApps;
        }
      };

    }
  ]);
