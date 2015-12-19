'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", "$location", "authToken", "$rootScope", "$http", "$window", "searchService", "AppPlatform", "apiService", "authService",
    function ($scope, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService) {

      var searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;

      // User info set
      var userInfo = {};
      authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

      // Sets user permissions
      authService.permissions()
        .success(function(data) {
          searchCtrl.canViewStorewideSdks = data.can_view_storewide_sdks;
          searchCtrl.godMode = data.god_mode;
        });

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function(isTablePageChange) {

        var urlParams = $location.url().split('/search')[1]; // If url params not provided
        var routeParams = $location.search();

        /* Compile Object with All Filters from Params */
        if (routeParams.app) var appParams = JSON.parse(routeParams.app);
        if (routeParams.company) var companyParams = JSON.parse(routeParams.company);
        if (routeParams.custom) var customParams = JSON.parse(routeParams.custom);
        if (routeParams.platform) var platform = JSON.parse(routeParams.platform);
        var allParams = appParams ? appParams : [];
        if (routeParams.custom && customParams['customKeywords'] && customParams['customKeywords'][0]) allParams['customKeywords'] = customParams['customKeywords'];
        for (var attribute in companyParams) {
          allParams[attribute] = companyParams[attribute];
        }

        console.log('Platform pre parse', routeParams.platform);
        console.log('Platform post parse', platform);
        console.log('platform.appPlatform!!', platform.appPlatform);
        console.log('APP_PLATFORM', 'PRE', APP_PLATFORM);

        searchCtrl.appPlatform.platform = platform.appPlatform;
        var APP_PLATFORM = platform.appPlatform;

        console.log('APP_PLATFORM', 'POST', APP_PLATFORM);

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

        $rootScope.dashboardSearchButtonDisabled = true;
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
            $rootScope.currentPage = data.pageNum;
            searchCtrl.currentPage = data.pageNum;
            if(!isTablePageChange) {searchCtrl.resultsSortCategory = 'appName'}; // if table page change, set default sort
            if(!isTablePageChange) {searchCtrl.resultsOrderBy = 'ASC'}; // if table page change, set default order

            var submitSearchEndTime = new Date().getTime();
            var submitSearchElapsedTime = submitSearchEndTime - submitSearchStartTime;

            /* -------- Mixpanel Analytics Start -------- */
            var searchQueryPairs = {};
            var searchQueryFields = [];
            var sdkNames = [];
            $rootScope.tags.forEach(function(tag) {
              searchQueryPairs[tag.parameter] = tag.value;
              searchQueryFields.push(tag.parameter);
              if(tag.parameter == 'sdkNames' && tag.parameter == 'downloads' ) {
                sdkNames.push(tag.value.name);
              }
            });
            searchQueryPairs['tags'] = searchQueryFields;
            searchQueryPairs['numOfApps'] = data.resultsCount;
            searchQueryPairs['elapsedTimeInMS'] = submitSearchElapsedTime;
            searchQueryPairs['platform']  = APP_PLATFORM;
            mixpanel.track(
              "Filter Query Successful",
              searchQueryPairs
            );
            /* -------- Mixpanel Analytics End -------- */
            /* -------- Slacktivity Alerts -------- */
            if($rootScope.sdkFilterPresent && userInfo.email && userInfo.email.indexOf('mightysignal') < 0) {
              var slacktivityData = {
                "title": "SDK Filter Query",
                "fallback": "SDK Filter Query",
                "color": "#FFD94D", // yellow
                "userEmail": userInfo.email,
                "sdkNames": sdkNames.join(', '),
                "tags": searchQueryFields.join(', '),
                "numOfApps": data.resultsCount
              };
              if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
              window.Slacktivity.send(slacktivityData);
            }
            /* -------- Slacktivity Alerts End -------- */
          })
          .error(function(data, status) {
            $rootScope.dashboardSearchButtonDisabled = false;
            mixpanel.track(
              "Filter Query Failed",
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

      searchCtrl.submitPageChange = function(currentPage) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Table Page Changed", {
            "page": currentPage,
            "tags": $rootScope.tags,
            "appPlatform": APP_PLATFORM
          }
        );
        /* -------- Mixpanel Analytics End -------- */

        console.log('PAGE CHANGE', currentPage, 'CATEGORY', searchCtrl.resultsSortCategory, 'ORDER', searchCtrl.resultsOrderBy);

        var urlParams = searchService.queryStringParameters($rootScope.tags, currentPage, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy);
        $location.url('/search?' + urlParams);
        searchCtrl.loadTableData(true);
        $rootScope.currentPage = currentPage;
        var end, start;
        return start = (currentPage - 1) * $rootScope.numPerPage, end = start + $rootScope.numPerPage;
      };

      // When orderby/sort arrows on dashboard table are clicked
      searchCtrl.sortApps = function(category, order) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Table Sorting Changed", {
            "category": category,
            "order": order,
            "appPlatform": APP_PLATFORM
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        var firstPage = 1;
        $rootScope.dashboardSearchButtonDisabled = true;
        apiService.searchRequestPost($rootScope.tags, firstPage, $rootScope.numPerPage, category, order)
          .success(function(data) {
            $scope.queryInProgress = false;
            searchCtrl.apps = data.results;
            searchCtrl.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            $rootScope.currentPage = 1;
            searchCtrl.currentPage = 1;
            searchCtrl.resultsSortCategory = category;
            searchCtrl.resultsOrderBy = order;
          })
          .error(function() {
            $scope.queryInProgress = false;
            $rootScope.dashboardSearchButtonDisabled = false;
          });
        };

      searchCtrl.appsDisplayedCount = function() {
        var lastPageMaxApps = $rootScope.numPerPage * searchCtrl.currentPage;
        var baseAppNum = $rootScope.numPerPage * (searchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > searchCtrl.numApps) {
          return "" + baseAppNum.toLocaleString() + " - " + searchCtrl.numApps.toLocaleString();
        } else {
          return "" + baseAppNum.toLocaleString() + " - " + lastPageMaxApps.toLocaleString();
        }
      };

      // Computes class for last updated data in Last Updated column rows
      searchCtrl.getLastUpdatedDaysClass = function(lastUpdatedDays) {
        return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
      };

      searchCtrl.exportAllToCsv = function() {
        apiService.exportAllToCsv($location.url().split('/search')[1])
          .success(function (content) {
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
            hiddenElement.target = '_blank';
            hiddenElement.download = 'all_results.csv';
            hiddenElement.click();
          });
      };

    }
  ]);
