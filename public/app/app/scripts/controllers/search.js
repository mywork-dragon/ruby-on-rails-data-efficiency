'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", '$timeout', '$route', '$sce', 'listApiService', 'savedSearchApiService', "$location", "authToken", "$rootScope", "$http", "$window", "searchService", "AppPlatform", "apiService", "authService", 'slacktivity', "filterService", "$uibModal",
    function ($scope, $timeout, $route, $sce, listApiService, savedSearchApiService, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService, slacktivity, filterService, $uibModal) {

      var searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;

      $scope.refreshSlider = function () {
        $timeout(function () {
          $scope.$broadcast('rzSliderForceRender');
        }, 200);
      };

      $scope.engagementOptions = function(id) {
        var range = id.split('-')
        return {
          id: id,
          name: $scope.intToUserbase(range[1]) + '-' + $scope.intToUserbase(range[2]),
          minValue: range[1],
          maxValue: range[2],
          options: {
            id: id,
            floor: 0,
            ceil: 8,
            showTicksValues: true,
            onEnd: function(sliderId, modelValue, highValue, pointerType) {
              for(var i = 0; i < $scope.complexFilters.userbase.or.length; i++){
                var filter = $scope.complexFilters.userbase.or[i]
                if (filter.userbase && filter.userbase.options && filter.userbase.options.id == sliderId) {
                  var newId = filter.status + '-' + modelValue + '-' + highValue
                  var newName = $scope.intToUserbase(modelValue) + '-' + $scope.intToUserbase(highValue)
                  filterService.changeFilter('userbaseFiltersOr', $scope.filterToTag(filter, 'userbase'), {id: newId, name: newName}, $scope.complexFilterDisplayText('userbase', 'or', filter));
                  $scope.complexFilters.userbase.or[i].userbase.id = newId
                  $scope.complexFilters.userbase.or[i].userbase.options.id = newId
                  break;
                }
              }
            },
            translate: function(value, sliderId, label) {
              return $scope.intToUserbase(value)
            }
          }
        };
      }

      $scope.intToUserbase = function(value) {
        switch (Number(value)) {
          case 0:
            return value;
          case 1:
            return '10k'
          case 2:
            return '50k'
          case 3:
            return '100k'
          case 4:
            return '500k'
          case 5:
            return '1M'
          case 6:
            return '5M'
          case 7:
            return '10M'
          case 8:
            return '50M+'
        }
      }

      $scope.complexFilters = {
        sdk: {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]},
        sdkCategory: {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]},
        location: {or: [{status: "0", state: '0'}], and: [{status: "0", state: '0'}]},
        userbase: {or: [{status: "0"}], and: [{status: "0"}]}
      }

      $scope.userbaseOptions = [
        {id: 1, name: 'Elite'},
        {id: 2, name: 'Strong'},
        {id: 3, name: 'Moderate'},
        {id: 4, name: 'Weak'},
      ]

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

      $scope.sdkDropdownSettings = function (filter) {
        const sdkCount = $rootScope.sdkCategories[filter.sdkCategory.name].sdks.length;
        return {
          buttonClasses: '',
          scrollable: sdkCount > 10,
          showCheckAll: sdkCount > 1,
          showUncheckAll: sdkCount > 1,
          template: '<img class="popover-icon" ng-src="{{option.icon}}" alt="icon" />{{option.name}}'
        }
      }

      searchCtrl.categoryCustomText = {
        buttonDefaultText: 'CATEGORIES',
      };

      searchCtrl.sdkDropdownText = {
        buttonDefaultText: 'SDKs',
        dynamicButtonTextSuffix: 'SDKs selected'
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

      $scope.emptyApps = function() {
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
        switch(filter_type) {
          case 'sdk':
            return $scope.complexFilters[filter_type][filter_operation].push({status: "0", date: "0"})
          case 'sdkCategory':
            return $scope.complexFilters[filter_type][filter_operation].push({status: "0", date: "0"})
          case 'location':
            return $scope.complexFilters[filter_type][filter_operation].push({status: "0", state: '0'})
          default:
            return $scope.complexFilters[filter_type][filter_operation].push({status: "0"})
        }
      }

      $scope.complexFilterKey = function(filter_type, filter_operation) {
        var filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1)
        return filter_type + 'Filters' + filterOperationShort
      }

      $scope.complexFilterDisplayText = function(filter_type, filter_operation, filter) {
        var filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1)
        switch(filter_type) {
          case 'sdk':
            return filterService.sdkDisplayText(filter, filterOperationShort, 'sdk')
          case 'sdkCategory':
            return filterService.sdkDisplayText(filter, filterOperationShort, 'sdkCategory')
          case 'location':
            return filterService.locationDisplayText(filter, filterOperationShort)
          case 'userbase':
            return filterService.userbaseDisplayText(filter, filterOperationShort)
        }
      }

      $scope.changedComplexFilter = function(filter, field, old_filter, filter_type, filter_operation) {
        old_filter = JSON.parse(old_filter)
        // if is userbase filter or location filter with different status we should remove the old filter after adding the new one
        if ((filter_type == 'userbase' && filter[field] != 0) || ((filter_type != 'sdk' && filter_type != 'sdkCategory') && old_filter.status != filter.status))  {
          if (filter_type == 'userbase' && filter[field] != 0) {
            filter[filter_type] = $scope.engagementOptions(filter.status + '-0-8')
            var customName = $scope.intToUserbase(filter[filter_type].minValue) + '-' + $scope.intToUserbase(filter[filter_type].maxValue)
            filterService.addFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type), $scope.complexFilterDisplayText(filter_type, filter_operation, filter), false, customName);
          } else { // is location filter
            filter[filter_type] = null
          }
          if (old_filter[filter_type]) {
            filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(old_filter, filter_type));
          }
        } else if (old_filter[filter_type]) { // is sdk filter and has sdk selected
          filterService.changeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(old_filter, filter_type), {[field]: filter[field]}, $scope.complexFilterDisplayText(filter_type, filter_operation, filter))
        }
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

      $scope.sdkSelectEvents = {
        onSelectionChanged: function () {
          filterService.clearAllSdkCategoryTags();
          ['and', 'or'].forEach(filterOperation => {
            $scope.complexFilters.sdkCategory[filterOperation].forEach(filter => {
              if (filter.sdkCategory) {
                filterService.addFilter($scope.complexFilterKey('sdkCategory', filterOperation), $scope.filterToTag(filter, 'sdkCategory'), $scope.complexFilterDisplayText('sdkCategory', filterOperation, filter), false, filter.sdkCategory.name);
              }
            })
          })
        }
      }

      $scope.selectedAndSdk = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'and')
      }

      $scope.selectedOrSdk = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'or')
      }

      $scope.selectedAndSdkCategory = function (category, index) {
        const object = _.cloneDeep(category)
        object.selectedSdks = category.sdks.map(sdk => ({ id: sdk.id }))
        delete object.sdks
        $scope.selectedComplexName(object, index, 'sdkCategory', 'and')
      }

      $scope.selectedOrSdkCategory = function (category, index) {
        const object = _.cloneDeep(category)
        object.selectedSdks = category.sdks.map(sdk => ({ id: sdk.id }))
        delete object.sdks
        $scope.selectedComplexName(object, index, 'sdkCategory', 'or')
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

        $scope.complexFilters[filter_type][filter_operation][index][filter_type] = object
        var customName = object.name
        var filter = $scope.complexFilters[filter_type][filter_operation][index]
        filterService.addFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type), $scope.complexFilterDisplayText(filter_type, filter_operation, filter), false, object.name);
      }

      $scope.filterToTag = function(filter, filter_type) {
        switch(filter_type) {
          case 'sdk':
            return {id: filter.sdk.id, status: filter.status, date: filter.date, name: filter.sdk.name}
          case 'sdkCategory':
            return {id: filter.sdkCategory.id, status: filter.status, date: filter.date, name: filter.sdkCategory.name, selectedSdks: $scope.checkFilterSelectedSdks(filter)}
          case 'location':
            return {id: filter.location.id, status: filter.status, name: filter.location.name, state: filter.state}
          case 'userbase':
            if (filter.status == 0) {
              return {id: filter.userbase.id, status: filter.status, name: filter.userbase.name}
            } else {
              return {id: filter.userbase.options.id, status: filter.status, name: filter.userbase.name}
            }
        }
      }

      $scope.checkFilterSelectedSdks = function (filter) {
        const categorySdkCount = $rootScope.sdkCategories[filter.sdkCategory.name].sdks.length;
        const filterSdkCount = filter.sdkCategory.selectedSdks.length;
        if (filterSdkCount == categorySdkCount) {
          return "all";
        }
        return filter.sdkCategory.selectedSdks.map(sdk => sdk.id)
      }

      $scope.checkTagSelectedSdks = function (tag) {
        if (tag.selectedSdks == "all") {
          return $rootScope.sdkCategories[tag.name].sdks.map(sdk => ({ id: sdk.id }))
        }
        return tag.selectedSdks.map(id => ({ id: id }))
      }

      $scope.tagToFilter = function(tag, filter_type) {
        switch(filter_type) {
          case 'sdk':
            return {status: tag.status, date: tag.date, sdk: {id: tag.id, name: tag.name}}
          case 'sdkCategory':
            return {status: tag.status, date: tag.date, sdkCategory: {id: tag.id, name: tag.name, selectedSdks: $scope.checkTagSelectedSdks(tag)}}
          case 'location':
            return {status: tag.status, location: {id: tag.id, name: tag.name}, state: tag.state}
          case 'userbase':
            if (tag.status == 0) {
              return {status: tag.status, userbase: {id: tag.id, name: tag.name}}
            } else {
              return {status: tag.status, userbase: $scope.engagementOptions(tag.id)}
            }
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
        switch(key) {
          case 'sdkFiltersAnd':
            $scope.addComplexFilter('sdk', 'and', $scope.tagToFilter(arrayItem, 'sdk'))
            break
          case 'sdkFiltersOr':
            $scope.addComplexFilter('sdk', 'or', $scope.tagToFilter(arrayItem, 'sdk'))
            break
          case 'sdkCategoryFiltersAnd':
            $scope.addComplexFilter('sdkCategory', 'and', $scope.tagToFilter(arrayItem, 'sdkCategory'))
            break
          case 'sdkCategoryFiltersOr':
            $scope.addComplexFilter('sdkCategory', 'or', $scope.tagToFilter(arrayItem, 'sdkCategory'))
            break
          case 'locationFiltersOr':
            $scope.addComplexFilter('location', 'or', $scope.tagToFilter(arrayItem, 'location'))
            break
          case 'locationFiltersAnd':
            $scope.addComplexFilter('location', 'and', $scope.tagToFilter(arrayItem, 'location'))
            break
          case 'userbaseFiltersOr':
            $scope.addComplexFilter('userbase', 'or', $scope.tagToFilter(arrayItem, 'userbase'))
            break
          case 'categories':
            $scope.addCategoryFilter(arrayItem)
            break
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
            $rootScope.numApps = data.resultsCount;
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
            let sdkCategoryFilterPresent = false;
            let sdkFilterPresent = false;
            const sdkCategoryFilters = { and: [], or: [] }
            const sdkFilters = [];
            $rootScope.tags.forEach(function(tag) {
              searchQueryPairs[tag.parameter] = tag.value;
              searchQueryFields.push(tag.parameter);
              if(tag.parameter == 'sdkNames' && tag.parameter == 'downloads' ) {
                sdkNames.push(tag.value.name);
              } else if (tag.parameter == 'sdkCategoryFiltersAnd') {
                sdkCategoryFilterPresent = true;
                sdkCategoryFilters.and.push({ category: tag.value.name, selectedSdks: tag.value.selectedSdks })
              } else if (tag.parameter == 'sdkCategoryFiltersOr') {
                sdkCategoryFilterPresent = true;
                sdkCategoryFilters.or.push({ category: tag.value.name, selectedSdks: tag.value.selectedSdks })
              } else if (tag.parameter.includes('sdkFilters')) {
                sdkFilterPresent = true;
                sdkFilters.push(tag.value.name)
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

            if (sdkCategoryFilterPresent) {
              mixpanel.track(
                "SDK Category Filter Used",
                sdkCategoryFilters
              )
            }

            if (sdkFilterPresent) {
              mixpanel.track(
                "SDK Individual Filter Used",
                { "sdks": sdkFilters }
              )
            }

            if(searchQueryPairs['locationFiltersAnd'] || searchQueryPairs['locationFiltersOr']) {
              var slacktivityData = {
                "title": "Location Filter Query",
                "fallback": "Location Filter Query",
                "color": "#FFD94D", // yellow
                "locationFiltersAnd": JSON.stringify(searchQueryPairs['locationFiltersAnd']),
                "locationFiltersOr": JSON.stringify(searchQueryPairs['locationFiltersOr']),
                "numOfApps": data.resultsCount
              };
              slacktivity.notifySlack(slacktivityData);
            }

            if(searchQueryPairs['userbaseFiltersAnd'] || searchQueryPairs['userbaseFiltersOr']) {
              var slacktivityData = {
                "title": "MAU/Userbase Filter Query",
                "fallback": "MAU/Userbase Filter Query",
                "color": "#FFD94D", // yellow
                "userbaseFiltersAnd": JSON.stringify(searchQueryPairs['userbaseFiltersAnd']),
                "userbaseFiltersOr": JSON.stringify(searchQueryPairs['userbaseFiltersOr']),
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

      // Saved searches

      savedSearchApiService.getSavedSearches().success(function(data) {
        searchCtrl.savedSearches = {};
        searchCtrl.searchName = "";
        data.forEach(search => {
          searchCtrl.savedSearches[search.id] = search;
        })
        searchCtrl.hasSearches = checkSearches();
      })

      function checkSearches () {
        return Object.keys(searchCtrl.savedSearches).length > 0;
      }

      searchCtrl.onSavedSearchChange = function(id) {
        $rootScope.tags = [];
        $scope.emptyApps();
        const savedSearch = searchCtrl.savedSearches[id];
        $location.url('/search?' +  savedSearch.search_params);
        searchCtrl.loadTableData();

        /* -------- Mixpanel Analytics Start -------- */
        const slacktivityData = {
          "title": "Previous Saved Search Loaded",
          "fallback": "Previous Saved Search Loaded",
          "color": "#FFD94D",
          "Name": savedSearch.name,
          "Parameters": savedSearch.search_params
        }
        slacktivity.notifySlack(slacktivityData);
        mixpanel.track(
          "Previous Saved Search Loaded", {
            "name": savedSearch.name,
            "parameters": savedSearch.search_params
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }

      searchCtrl.createSavedSearch = function(name) {
        const queryString = searchService.queryStringParameters($rootScope.tags, 1, 100);
        savedSearchApiService.createSavedSearch(name, queryString)
          .success(function(data) {
            searchCtrl.savedSearches[data.id] = data;
            searchCtrl.searchName = "";
            searchCtrl.hasSearches = checkSearches();
            savedSearchApiService.toast('search-create-success');

            /* -------- Analytics Start -------- */
            const slacktivityData = {
              "title": "New Saved Search Created",
              "fallback": "New Saved Search Created",
              "color": "#FFD94D",
              "Name": data.name,
              "Parameters": data.search_params
            }
            slacktivity.notifySlack(slacktivityData);
            mixpanel.track(
              "New Saved Search Created", {
                "name": data.name,
                "parameters": data.search_params
              }
            );
            /* -------- Analytics End -------- */
          })
          .error(function(error) {
            savedSearchApiService.toast('search-create-failure');
          });
      }

      // searchCtrl.updateSavedSearch = function() {
      //   const queryString = searchService.queryStringParameters($rootScope.tags);
      //   savedSearchApiService.updateSavedSearch(searchCtrl.currentSavedSearchId, queryString)
      //     .success(function(data) {
      //       savedSearchApiService.toast('search-update-success');
      //       searchCtrl.savedSearches[data.id] = data;
      //     })
      //     .error(function(error) {
      //       savedSearchApiService.toast('search-update-failure');
      //     })
      // }

      searchCtrl.setCurrentSearchId = function(id, $event) {
        $event.stopPropagation();
        var modalInstance = $uibModal.open({
          animation: true,
          ariaLabelledBy: 'searchDeleteModalTitle',
          ariaDescribedBy: 'searchDeleteModalBoday',
          templateUrl: 'search-delete.html',
          controller: 'ModalInstanceCtrl',
          controllerAs: '$ctrl',
          resolve: {
            id: function () {
              return id;
            }
          }
        })

        modalInstance.result.then(function (id) {
          searchCtrl.deleteSavedSearch(id)
        })
      }

      searchCtrl.deleteSavedSearch = function(id) {
        savedSearchApiService.deleteSavedSearch(id)
          .success(function(data) {
            delete searchCtrl.savedSearches[data.id];
            savedSearchApiService.toast('search-delete-success');
            searchCtrl.hasSearches = Object.keys(searchCtrl.savedSearches).length > 0;

            /* -------- Mixpanel Analytics Start -------- */
            const slacktivityData = {
              "title": "Saved Search Deleted",
              "fallback": "Saved Search Deleted",
              "color": "#FFD94D",
              "Name": data.name,
              "Parameters": data.search_params
            }
            slacktivity.notifySlack(slacktivityData);
            mixpanel.track(
              "Saved Search Deleted", {
                "name": data.name,
                "parameters": data.search_params
              }
            );
            /* -------- Mixpanel Analytics End -------- */

          })
          .error(function(error) {
            savedSearchApiService.toast('search-delete-failure');
          })
      }

      // When orderby/sort arrows on dashboard table are clicked
      searchCtrl.sortApps = function(category, order) {
        var sign = order == 'desc' ? '-' : ''
        $scope.rowSort = sign + category

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
      };

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
        apiService.getSdkCategories().success(data => {
          $rootScope.sdkCategories = data;
          searchCtrl.loadTableData();
        })
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
