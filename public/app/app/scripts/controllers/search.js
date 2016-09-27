'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", '$route', '$sce', 'listApiService', "$location", "authToken", "$rootScope", "$http", "$window", "searchService", "AppPlatform", "apiService", "authService", 'slacktivity', "filterService",
    function ($scope, $route, $sce, listApiService, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService, slacktivity, filterService) {

      var searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;

      $scope.complexFilters = {
        sdk: {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]},
        location: {or: [{status: "0", state: '0'}], and: [{status: "0", state: '0'}]}
      }

      $scope.listButtonDisabled = true
      searchCtrl.apps = []

      // Sets user permissions
      authService.permissions()
        .success(function(data) {
          searchCtrl.canViewStorewideSdks = data.can_view_storewide_sdks;
          $scope.canViewExports = data.can_view_exports;
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

      $scope.status = {
         isopen: false
       };

       $scope.toggled = function(open) {
         $log.log('Dropdown is now: ', open);
       };

       $scope.toggleDropdown = function($event) {
         $event.preventDefault();
         $event.stopPropagation();
         $scope.status.isopen = !$scope.status.isopen;
       };

      $scope.sdkAutocompleteUrl = function() {
        return API_URI_BASE + "api/sdk/autocomplete?platform=" + AppPlatform.platform + "&query="
      }

      $scope.toggledPlatform = function() {
        searchCtrl.apps = [];
        searchCtrl.numApps = 0;
      }

      $scope.locationAutocompleteUrl = function(status) {
        return API_URI_BASE + "api/location/autocomplete?status=" + status + "&query="
      }

      $scope.addCategoryFilter = function(category) {
        var found = false
        for (var i in $rootScope.categoryModel) {
          if ($rootScope.categoryModel[i].id == category) found = true
        }
        if (!found) $rootScope.categoryModel.push({id: category, label: category})
      }

      $scope.addComplexFilter = function(filter_type, filter_operation, filter) {
        if (filter) { 
          var found = false // only allow unique filters
          for (var i in $scope.complexFilters[filter_type][filter_operation]) {
            var existingFilter = $scope.complexFilters[filter_type][filter_operation][i]
            if (existingFilter[filter_type] && filter[filter_type] && $scope.filterIsEqualToFilter(existingFilter, filter, filter_type)) found = true
          }
          if (!found) $scope.complexFilters[filter_type][filter_operation].unshift(filter)
        } else {
          $scope.addBlankComplexFilter(filter_type, filter_operation)
        }
      }

      $scope.addBlankComplexFilter = function(filter_type, filter_operation) {
        if (filter_type == 'location') {  
          $scope.complexFilters[filter_type][filter_operation].push({status: "0", state: '0'})
        } else {
          $scope.complexFilters[filter_type][filter_operation].push({status: "0", date: "0"})
        }
      }

      $scope.complexFilterKey = function(filter_type, filter_operation) {
        var filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1)
        return filter_type + 'Filters' + filterOperationShort
      }

      $scope.complexFilterDisplayText = function(filter_type, filter_operation, filter) {
        var filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1)
        if (filter_type == 'sdk') {
          return filterService.sdkDisplayText(filter, filterOperationShort)
        } else {
          return filterService.locationDisplayText(filter, filterOperationShort)
        }
      }

      $scope.changedComplexFilter = function(filter, field, old_filter, filter_type, filter_operation) {
        old_filter = JSON.parse(old_filter)
        if (!old_filter[filter_type]) return
        filterService.changeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(old_filter, filter_type), {[field]: filter[field]}, $scope.complexFilterDisplayText(filter_type, filter_operation, filter))
      }

      $scope.removeComplexFilter = function(filter_type, filter_operation, filter) {
        var index = $scope.complexFilters[filter_type][filter_operation].indexOf(filter);
        if (index > -1) {
          var filter = $scope.complexFilters[filter_type][filter_operation][index]
          if (filter[filter_type]) {
            filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type));
          }
          $scope.complexFilters[filter_type][filter_operation].splice(index, 1);
          if (!$scope.complexFilters[filter_type][filter_operation].length) $scope.addComplexFilter(filter_type, filter_operation)
        }
      }

      $scope.removeComplexNameFilter = function(filter_type, filter_operation, index) {
        var filter = $scope.complexFilters[filter_type][filter_operation][index]
        filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type));
        $scope.complexFilters[filter_type][filter_operation][index][filter_type] = null;
      }

      $scope.selectedAndSdk = function ($item) {  
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'and')
      }

      $scope.selectedOrSdk = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'or')
      }

      $scope.selectedAndLocation = function ($item) {  
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'location', 'and')
      }

      $scope.selectedOrLocation = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'location', 'or')
      }

      $scope.selectedComplexName = function(object, index, filter_type, filter_operation) {
        if (typeof object === 'string' || object instanceof String) {
          object = $scope.findAppStore(object)
        }
        var filter = $scope.complexFilters[filter_type][filter_operation][index]
        filter[filter_type] = object
        var customName = object.name
        filterService.addFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type), $scope.complexFilterDisplayText(filter_type, filter_operation, filter), false, object.name);
      }

      $scope.filterToTag = function(filter, filter_type) {
        if (filter_type == 'sdk') {
          return {id: filter.sdk.id, status: filter.status, date: filter.date, name: filter.sdk.name}
        } else {
          return {id: filter.location.id, status: filter.status, name: filter.location.name, state: filter.state}
        }
      }

      $scope.tagToFilter = function(tag, filter_type) {
        if (filter_type == 'sdk') {
          return {status: tag.status, date: tag.date, sdk: {id: tag.id, name: tag.name}}
        } else {
          return {status: tag.status, location: {id: tag.id, name: tag.name}, state: tag.state}
        }
      }

      $scope.filterIsEqualToTag = function(filter, tag, filter_type) {
        return filter.status == tag.value.status && filter[filter_type].id == tag.value.id && filter.date == tag.value.date && filter.state == tag.value.state
      }

      $scope.filterIsEqualToFilter = function(filter1, filter2, filter_type) {
        return filter1.status == filter2.status && filter1[filter_type].id == filter2[filter_type].id && filter1.date == filter2.date && filter1.state == filter2.state
      }

      $scope.$watchCollection('$root.tags', function () {
        if ($rootScope.tags) {
          Object.keys($scope.complexFilters).forEach(function(filterType) {
            var filters = $scope.complexFilters[filterType];
            Object.keys(filters).forEach(function(filterOperation) {
              var opFilters = $scope.complexFilters[filterType][filterOperation];
              for (var index = 0; index < opFilters.length; index++) { 
                var found = false;
                var filter = opFilters[index]
                if (filter[filterType]) {
                  $rootScope.tags.forEach(function(tag) {
                    var targetParameter = $scope.complexFilterKey(filterType, filterOperation)
                    if (targetParameter == tag.parameter && $scope.filterIsEqualToTag(filter, tag, filterType)) {
                      found = true;
                    }
                  });
                } else {
                  continue;
                }
               
                if (!found) {
                  opFilters.splice(index, 1);
                  index--;
                }
              }
              if (!opFilters.length) $scope.addBlankComplexFilter(filterType, filterOperation)
            })
          })
        }
        $scope.listButtonDisabled = true
      })

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

      $scope.rebuildFromURLParam = function(key, arrayItem) {
        if (key == 'sdkFiltersAnd') {
          $scope.addComplexFilter('sdk', 'and', $scope.tagToFilter(arrayItem, 'sdk'))
        } else if (key == 'sdkFiltersOr') {
          $scope.addComplexFilter('sdk', 'or', $scope.tagToFilter(arrayItem, 'sdk'))
        } else if (key == 'locationFiltersOr') {
          $scope.addComplexFilter('location', 'or', $scope.tagToFilter(arrayItem, 'location'))
        } else if (key == 'locationFiltersAnd') {
          $scope.addComplexFilter('location', 'and', $scope.tagToFilter(arrayItem, 'location'))
        } else if (key == 'categories') { 
          $scope.addCategoryFilter(arrayItem)
        }
      }

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function(isTablePageChange) {
        var routeParams = $location.search();
        var urlParams = $location.url().split('/search')[1]; // If url params not provided

        /* Compile Object with All Filters from Params */
        if (routeParams.app) var appParams = JSON.parse(routeParams.app);
        if (routeParams.company) var companyParams = JSON.parse(routeParams.company);
        if (routeParams.platform) var platform = JSON.parse(routeParams.platform);
        
        $scope.filters = {company: companyParams, platform: platform, app: appParams}

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
              $scope.rebuildFromURLParam(key, arrayItem)
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
            $scope.listButtonDisabled = false
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

      // When main Dashboard search button is clicked
      searchCtrl.submitSearch = function() {
        var urlParams = searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy, $scope.list);
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

        var urlParams = searchService.queryStringParameters($rootScope.tags, currentPage, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy, $scope.list);
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

      apiService.getScannedSdkNum().success(function(data) {
        $scope.scannedAndroidSdkNum = data.scannedAndroidSdkNum;
        $scope.scannedIosSdkNum = data.scannedIosSdkNum;
      });

      $scope.getList = function() {
        var routeParams = $location.search();
        if (!routeParams.listId) return
        listApiService.getList(routeParams.listId).success(function(data) {
          $scope.list = data
        })
      }

      $scope.updateList = function() {
        var routeParams = $location.search();
        listApiService.updateList(routeParams.listId, $scope.filters)
        .success(function(data) {
          $scope.notify('saved-list-success'); 
        }).error(function() {
          $scope.notify('saved-list-error'); 
        })
      }

      $scope.notify = function(type) {
        listApiService.listNotify(type);
      };

      /* Only hit api if query string params are present */
      if($location.url().split('/search')[1]) {
        searchCtrl.loadTableData();
      }

      $scope.setTab = function() {
        var routeParams = $location.search();

        if (routeParams.listId) {
          $route.current.activeTab = 'lists'
        } else {
          $route.current.activeTab = 'search'
        }
      }

      $scope.getAppStores = function() {
        $http({
          method: 'get',
          url: $scope.locationAutocompleteUrl(1)
        })
        .success(function(data) {
          $scope.availableAppStores = data.results
        })
      }

      $scope.findAppStore = function(countryCode) {
        for (var i = 0; i < $scope.availableAppStores.length; i++) {
          if ($scope.availableAppStores[i].id == countryCode) {
            return $scope.availableAppStores[i]
          }
        }
        return null
      }

      $scope.getList()
      $scope.setTab()
      $scope.getAppStores()
    }
  ]);
