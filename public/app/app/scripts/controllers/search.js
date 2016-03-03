'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", '$sce', "$location", "authToken", "$rootScope", "$http", "$window", "searchService", "AppPlatform", "apiService", "authService",
    function ($scope, $sce, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService) {

      var searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;
      // User info set
      var userInfo = {};
      authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

      // Sets user permissions
      authService.permissions()
        .success(function(data) {
          searchCtrl.canViewStorewideSdks = data.can_view_storewide_sdks;
        });

      $scope.mobileExplanation = $sce.trustAsHtml('<p>How much the company cares about the app. Use this to filter out apps that are not actively being developed or marketed.</p>' + 
                                                  '<p>The Mobile Priority ranking is continuously improving as we collect more data and refine the algorithm.</p>' + 
                                                  'Currently, the rank is a function of how recently their app has been updated, and whether they advertise on Facebook. High: they have advertised on ' +
                                                  'Facebook or have updated within the past two months. Medium: Updated within last 2 - 4 months. Low: Last update > 4 months ago.</p>')
      $scope.fortuneExplanation = $sce.trustAsHtml('<p>Filters for companies in either the Fortune 500 or Fortune 1000 lists.</p>')
      $scope.adSpendExplanation = $sce.trustAsHtml('<p>Whether the company is paying for ads on Facebook to download the app. This is the leading indicator that the app has marketing budget.</p>' +
                                                   '<p>We determine this via a network of hundreds of people who report to us what mobile app adds they see when on Facebook.</p>' +
                                                   '<p>We are continuing to refine this tool to give more specifics. As of its current state, we’re denoting whether a company advertises on Facebook in a binary' +
                                                   'fashion – either they do (if an ad has been reported) or they don’t.</p>')
      $scope.userBaseExplanation = $sce.trustAsHtml('<p>An estimate of how many active users an app has.</p>' +
                                                    '<p>We derive this estimate based off of how many ratings per day an app has. Elite: 50,000 total ratings or 7 ratings per day average (for current release).' +
                                                    'Strong: 10,000 total ratings or 1 rating per day average (for current release). Moderate: 100 total ratings or 0.1 average rating per day average' + 
                                                    'for current release). Weak: anything less.</p>') 
      $scope.updatedExplanation = $sce.trustAsHtml('<p>Length of time from last update to app, as reported on the iOS and Google Play stores.</p>')
      $scope.categoryExplanation = $sce.trustAsHtml('<p>The category/genre of the app (same as iOS App Store categories).</p>')
      $scope.sdkOperatorExplanation = $sce.trustAsHtml('<p>Pick an operator used for all SDK filters. e.g. Should we show apps with Mixpanel SDK AND Amplitude SDK installed or should we show apps with Mixpanel SDK OR Amplitude SDK installed')
      
      $rootScope.categoryModel = [];
      searchCtrl.categorySettings = {
        buttonClasses: '',
        externalIdProp: '',
        dynamicTitle: false
      }
      searchCtrl.categoryCustomText = {
        buttonDefaultText: 'CATEGORIES',
      };

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

        searchCtrl.appPlatform.platform = platform.appPlatform;
        var APP_PLATFORM = platform.appPlatform;

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
        apiService.searchRequestPost($rootScope.tags, firstPage, $rootScope.numPerPage, category, order, searchCtrl.appPlatform.platform)
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
