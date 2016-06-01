'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", '$sce', "$location", "authToken", "$rootScope", "$http", "$window", "searchService", "AppPlatform", "apiService", "authService", 'slacktivity', "filterService",
    function ($scope, $sce, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService, slacktivity, filterService) {

      var searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;

      $scope.sdkFilters = {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]}
      searchCtrl.apps = []

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

      $scope.addCategoryFilter = function(category) {
        var found = false
        for (var i in $rootScope.categoryModel) {
          if ($rootScope.categoryModel[i].id == category) found = true
        }
        if (!found) $rootScope.categoryModel.push({id: category, label: category})
      }

      $scope.addSdkFilter = function(filter_type, filter) {
        if (filter) { 
          var found = false // only allow unique filters
          for (var i in $scope.sdkFilters[filter_type]) {
            var existingFilter = $scope.sdkFilters[filter_type][i]
            if (existingFilter.sdk && filter.sdk && $scope.filterIsEqualToFilter(existingFilter, filter)) found = true
          }
          if (!found) $scope.sdkFilters[filter_type].unshift(filter)
        } else {
          $scope.sdkFilters[filter_type].push({status: "0", date: "0"})
        }
      }

      $scope.changedSdkFilter = function(filter, field, old_filter, filter_type) {
        old_filter = JSON.parse(old_filter)
        var filterTypeShort = filter_type.substr(0, 1).toUpperCase() + filter_type.substr(1)
        filterService.changeFilter('sdkFilters' + filterTypeShort, $scope.filterToTag(old_filter), {[field]: filter[field]}, filterService.sdkDisplayText(filter, filterTypeShort))
      }

      $scope.removeSdkFilter = function(filter_type, filter) {
        var index = $scope.sdkFilters[filter_type].indexOf(filter);
        if (index > -1) {
          var filter = $scope.sdkFilters[filter_type][index]
          if (filter.sdk) {
            filterService.removeFilter('sdkFilters' + filter_type.substr(0, 1).toUpperCase() + filter_type.substr(1), $scope.filterToTag(filter));
          }
          $scope.sdkFilters[filter_type].splice(index, 1);
          if (!$scope.sdkFilters[filter_type].length) $scope.addSdkFilter(filter_type)
        }
      }

      $scope.removeSdkNameFilter = function(filter_type, index) {
        var filter = $scope.sdkFilters[filter_type][index]
        filterService.removeFilter('sdkFilters' + filter_type.substr(0, 1).toUpperCase() + filter_type.substr(1), $scope.filterToTag(filter));
        $scope.sdkFilters[filter_type][index].sdk = null;
      }

      $scope.selectedAndSdk = function ($item) {  
        $scope.selectedSdk($item, this.$parent.$index, 'and')
      }

      $scope.selectedOrSdk = function ($item) {
        $scope.selectedSdk($item, this.$parent.$index, 'or')
      }

      $scope.filterToTag = function(filter) {
        return {id: filter.sdk.id, status: filter.status, date: filter.date, name: filter.sdk.name}
      }

      $scope.tagToFilter = function(tag) {
        return {status: tag.status, date: tag.date, sdk: {id: tag.id, name: tag.name}}
      }

      $scope.filterIsEqualToTag = function(filter, tag) {
        return filter.status == tag.value.status && filter.sdk.id == tag.value.id && filter.date == tag.value.date
      }

      $scope.filterIsEqualToFilter = function(filter1, filter2) {
        return filter1.status == filter2.status && filter1.sdk.id == filter2.sdk.id && filter1.date == filter2.date
      }

      $scope.$watchCollection('$root.tags', function () {
        if ($rootScope.tags) {
          Object.keys($scope.sdkFilters).forEach(function(filterKey) {
            var filters = $scope.sdkFilters[filterKey];
            for (var index = 0; index < filters.length; index++) { 
              var found = false;
              var filter = filters[index]
              if (!filter.sdk) continue;
              $rootScope.tags.forEach(function(tag) {
                var targetParameter = filterKey == 'or' ? 'sdkFiltersOr' : 'sdkFiltersAnd';
                if (targetParameter == tag.parameter && $scope.filterIsEqualToTag(filter, tag)) {
                  found = true;
                }
              });
              if (!found) {
                filters.splice(index, 1);
                index--;
                if (!filters.length) filters.push({status: "0", date: "0"});
              }
            }
          })
        }
      });

      $scope.selectedSdk = function($item, index, filter_type) {
        var sdk = $item.originalObject
        var filter = $scope.sdkFilters[filter_type][index]
        filter.sdk = sdk
        var filterTypeShort = filter_type.substr(0, 1).toUpperCase() + filter_type.substr(1)
        filterService.addFilter('sdkFilters' + filterTypeShort, $scope.filterToTag(filter), filterService.sdkDisplayText(filter, filterTypeShort), false, sdk.name);
      }

      $scope.removedTag = function(tag) {
        if (tag.parameter == 'categories') {
          for(var i = $rootScope.categoryModel.length - 1; i >= 0 ; i--){
            // only check for value if value exists
            if($rootScope.categoryModel[i].label == tag.value){
              $rootScope.categoryModel.splice(i, 1);
            }
          }
        }
      }

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function(isTablePageChange) {

        var urlParams = $location.url().split('/search')[1]; // If url params not provided
        var routeParams = $location.search();

        /* Compile Object with All Filters from Params */
        if (routeParams.app) var appParams = JSON.parse(routeParams.app);
        if (routeParams.company) var companyParams = JSON.parse(routeParams.company);
        if (routeParams.platform) var platform = JSON.parse(routeParams.platform);
        var allParams = appParams ? appParams : [];
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
              if (key == 'sdkFiltersAnd') {
                $scope.addSdkFilter('and', $scope.tagToFilter(arrayItem))
              } else if (key == 'sdkFiltersOr') {
                $scope.addSdkFilter('or', $scope.tagToFilter(arrayItem))
              } else if (key == 'categories') {
                $scope.addCategoryFilter(arrayItem)
              }
            });
          } else {
            $rootScope.tags.push(searchService.searchFilters(key, value));
          }
        }

        $rootScope.dashboardSearchButtonDisabled = true;
        $rootScope.searchError = false
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
            searchCtrl.updateCSVUrl();
            if(!isTablePageChange) {searchCtrl.resultsSortCategory = 'name'}; // if table page change, set default sort
            if(!isTablePageChange) {searchCtrl.resultsOrderBy = 'asc'}; // if table page change, set default order

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

            if($rootScope.sdkFilterPresent) {
              var slacktivityData = {
                "title": "SDK Filter Query",
                "fallback": "SDK Filter Query",
                "color": "#FFD94D", // yellow
                "sdkNames": sdkNames.join(', '),
                "tags": searchQueryFields.join(', '),
                "numOfApps": data.resultsCount
              };
              slacktivity.notifySlack(slacktivityData);
            }
            /* -------- Slacktivity Alerts End -------- */
          })
          .error(function(data, status) {
            $rootScope.dashboardSearchButtonDisabled = false;
            $rootScope.searchError = true
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
        var urlParams = searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, category, order);
        $location.url('/search?' + urlParams);
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
          searchCtrl.updateCSVUrl();
        })
        .error(function() {
          $scope.queryInProgress = false;
          $rootScope.dashboardSearchButtonDisabled = false;
        });
      };

      // Computes class for last updated data in Last Updated column rows
      searchCtrl.getLastUpdatedDaysClass = function(lastUpdatedDays) {
        return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
      };

      searchCtrl.updateCSVUrl = function() {
        searchCtrl.csvUrl = API_URI_BASE + 'api/search/export_to_csv.csv' + $location.url().split('/search')[1] + '&access_token=' + authToken.get()
      }
    }
  ]);
