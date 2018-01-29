import angular from 'angular';
import mixpanel from 'mixpanel-browser';
import _ from 'lodash';
import moment from 'moment';

import 'components/export-permissions/export-permissions.directive';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .controller('SearchCtrl', ['$scope', '$timeout', 'listApiService', 'savedSearchApiService', '$location', 'authToken', '$rootScope', '$http', '$window', 'searchService', 'AppPlatform', 'apiService', 'authService', 'slacktivity', 'filterService', '$uibModal', 'loggitService', 'pageTitleService', '$q', '$state',
    function ($scope, $timeout, listApiService, savedSearchApiService, $location, authToken, $rootScope, $http, $window, searchService, AppPlatform, apiService, authService, slacktivity, filterService, $uibModal, loggitService, pageTitleService, $q, $state) {
      const searchCtrl = this; // same as searchCtrl = $scope
      searchCtrl.appPlatform = AppPlatform;

      if ($state.is('explore')) {
        pageTitleService.setTitle('MightySignal - Explore');
      }

      $scope.refreshSlider = function () {
        $timeout(() => {
          $scope.$broadcast('rzSliderForceRender');
        }, 200);
      };

      $scope.engagementOptions = function(id) {
        const range = id.split('-');
        return {
          id,
          name: `${$scope.intToUserbase(range[1])}-${$scope.intToUserbase(range[2])}`,
          minValue: range[1],
          maxValue: range[2],
          options: {
            id,
            floor: 0,
            ceil: 8,
            showTicksValues: true,
            onEnd(sliderId, modelValue, highValue) {
              for (let i = 0; i < $rootScope.complexFilters.userbase.or.length; i++) {
                const filter = $rootScope.complexFilters.userbase.or[i];
                if (filter.userbase && filter.userbase.options && filter.userbase.options.id === sliderId) {
                  const newId = `${filter.status}-${modelValue}-${highValue}`;
                  const newName = `${$scope.intToUserbase(modelValue)}-${$scope.intToUserbase(highValue)}`;
                  filterService.changeFilter('userbaseFiltersOr', $scope.filterToTag(filter, 'userbase'), { id: newId, name: newName }, $scope.complexFilterDisplayText('userbase', 'or', filter));
                  $rootScope.complexFilters.userbase.or[i].userbase.id = newId;
                  $rootScope.complexFilters.userbase.or[i].userbase.options.id = newId;
                  break;
                }
              }
            },
            translate(value) {
              return $scope.intToUserbase(value);
            },
          },
        };
      };

      $scope.intToUserbase = function(value) {
        switch (Number(value)) {
          case 0:
            return value;
          case 1:
            return '10k';
          case 2:
            return '50k';
          case 3:
            return '100k';
          case 4:
            return '500k';
          case 5:
            return '1M';
          case 6:
            return '5M';
          case 7:
            return '10M';
          case 8:
            return '50M+';
        }
      };

      $scope.userbaseOptions = [
        { id: 1, name: 'Elite' },
        { id: 2, name: 'Strong' },
        { id: 3, name: 'Moderate' },
        { id: 4, name: 'Weak' },
      ];

      $scope.dateOptions = {
        showWeeks: false,
        maxDate: new Date(),
      };

      $scope.sdkModalWidth = {
        width: '725px',
        transition: 'width .75s',
      };

      $scope.updateSdkModalWidth = function () {
        const filters = $rootScope.complexFilters;
        const sdkDateRangePresent = [filters.sdk.and, filters.sdk.or].some(filterGroup => filterGroup.some(filter => $scope.hasCustomDateRange(filter)));
        const sdkCategoryDateRangePresent = [filters.sdkCategory.and, filters.sdkCategory.or].some(filterGroup => filterGroup.some(filter => $scope.hasCustomDateRange(filter)));
        if (sdkCategoryDateRangePresent) {
          $scope.sdkModalWidth.width = '925px';
        } else if (sdkDateRangePresent) {
          $scope.sdkModalWidth.width = '800px';
        } else {
          $scope.sdkModalWidth.width = '725px';
        }
      };

      $scope.invalidDateRanges = false;

      $scope.checkDateRanges = function () {
        const filters = $rootScope.complexFilters;
        $scope.invalidDateRanges = [filters.sdk.and, filters.sdk.or, filters.sdkCategory.and, filters.sdkCategory.or].some(filterGroup => filterGroup.some((filter) => {
          if ($scope.hasCustomDateRange(filter)) {
            return $scope.hasInvalidDateRange(filter);
          }
          return false;
        }));
      };

      $scope.hasCustomDateRange = function (filter) {
        return filter.date === '7';
      };

      $scope.hasInvalidDateRange = function (filter) {
        return filter.dateRange ? filter.dateRange.from > filter.dateRange.until : false;
      };

      $scope.requiresDateRange = function (filter) {
        return ['0', '1'].includes(filter.status);
      };

      $scope.isOldFilter = function (filter) {
        return parseInt(filter.date, 10) >= 8;
      };

      $scope.getOldFilterText = function (filter) {
        switch (filter.date) {
          case '8':
            return 'Between 1 Week and 1 Month Ago';
          case '9':
            return 'Between 1 Month and 3 Months Ago';
          case '10':
            return 'Between 3 Months and 6 Months Ago';
          case '11':
            return 'Between 6 Months and 9 Months Ago';
          case '12':
            return 'Between 9 Months and 1 Year Ago';
          default:
            break;
        }
      };

      $scope.listButtonDisabled = true;
      searchCtrl.apps = [];

      authService.permissions()
        .success((data) => {
          searchCtrl.canViewStorewideSdks = data.can_view_storewide_sdks;
          $scope.canViewExports = data.can_view_exports;
        });

      searchCtrl.categorySettings = {
        buttonClasses: '',
        externalIdProp: '',
        dynamicTitle: false,
      };

      $scope.sdkDropdownSettings = function (filter) {
        const sdkCount = $rootScope.sdkCategories[filter.sdkCategory.name].sdks.length;
        return {
          buttonClasses: '',
          scrollable: sdkCount > 10,
          showCheckAll: sdkCount > 1,
          showUncheckAll: sdkCount > 1,
          template: '<img class="popover-icon" ng-src="{{option.icon}}" alt="icon" />{{option.name}}',
        };
      };

      searchCtrl.categoryCustomText = {
        buttonDefaultText: 'CATEGORIES',
      };

      searchCtrl.downloadsCustomText = {
        buttonDefaultText: 'DOWNLOADS',
      };

      searchCtrl.userbaseCustomText = {
        buttonDefaultText: 'USER BASE',
      };

      searchCtrl.mobilePriorityCustomText = {
        buttonDefaultText: 'MOBILE PRIORITY',
      };

      searchCtrl.sdkDropdownText = {
        buttonDefaultText: 'SDKs',
        dynamicButtonTextSuffix: 'SDKs selected',
      };

      $scope.status = {
        isopen: false,
      };

      $scope.toggleDropdown = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.status.isopen = !$scope.status.isopen;
      };

      $scope.sdkAutocompleteUrl = function() {
        return `${API_URI_BASE}api/sdk/autocomplete?platform=${AppPlatform.platform}&query=`;
      };

      $scope.emptyApps = function() {
        searchCtrl.apps = [];
        searchCtrl.numApps = 0;
      };

      $scope.formatDate = function (date) {
        return moment(date).format('L');
      };

      $scope.locationAutocompleteUrl = function(status) {
        return `${API_URI_BASE}api/location/autocomplete?status=${status}&query=`;
      };

      $scope.addDropdownFilter = function (parameter, item) {
        let found = false;
        let model;
        let value;
        switch (parameter) {
          case 'categories':
            model = $rootScope.categoryModel;
            value = { id: item, label: item };
            break;
          case 'downloads':
            model = $rootScope.downloadsModel;
            value = { id: item, label: $rootScope.downloadsFilterOptions[item].label };
            break;
          case 'mobilePriority':
            model = $rootScope.mobilePriorityModel;
            value = { id: item, label: item };
            break;
          case 'userBases':
            model = $rootScope.userbaseModel;
            value = { id: item, label: item };
            break;
        }
        for (const i in model) {
          if (model[i].id === value) found = true;
        }
        if (!found) model.push(value);
      };

      $scope.addComplexFilter = function(filter_type, filter_operation, filter) {
        if (filter) {
          let found = false; // only allow unique filters
          for (const i in $rootScope.complexFilters[filter_type][filter_operation]) {
            const existingFilter = $rootScope.complexFilters[filter_type][filter_operation][i];
            if (existingFilter[filter_type] && filter[filter_type] && $scope.filterIsEqualToFilter(existingFilter, filter, filter_type)) found = true;
          }
          if (!found) $rootScope.complexFilters[filter_type][filter_operation].unshift(filter);
        } else {
          $scope.addBlankComplexFilter(filter_type, filter_operation);
        }
      };

      $scope.addBlankComplexFilter = function(filter_type, filter_operation) {
        switch (filter_type) {
          case 'sdk':
            return $rootScope.complexFilters[filter_type][filter_operation].push({ status: '0', date: '0' });
          case 'sdkCategory':
            return $rootScope.complexFilters[filter_type][filter_operation].push({ status: '0', date: '0' });
          case 'location':
            return $rootScope.complexFilters[filter_type][filter_operation].push({ status: '0', state: '0' });
          default:
            return $rootScope.complexFilters[filter_type][filter_operation].push({ status: '0' });
        }
      };

      $scope.complexFilterKey = function(filter_type, filter_operation) {
        const filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1);
        return `${filter_type}Filters${filterOperationShort}`;
      };

      $scope.complexFilterDisplayText = function(filter_type, filter_operation, filter) {
        const filterOperationShort = filter_operation.substr(0, 1).toUpperCase() + filter_operation.substr(1);
        switch (filter_type) {
          case 'sdk':
            return filterService.sdkDisplayText(filter, filterOperationShort, 'sdk');
          case 'sdkCategory':
            return filterService.sdkDisplayText(filter, filterOperationShort, 'sdkCategory');
          case 'location':
            return filterService.locationDisplayText(filter, filterOperationShort);
          case 'userbase':
            return filterService.userbaseDisplayText(filter, filterOperationShort);
        }
      };

      $scope.changedComplexFilter = function(filter, field, oldFilter, filter_type, filter_operation) {
        oldFilter = JSON.parse(oldFilter);
        // if is userbase filter or location filter with different status we should remove the old filter after adding the new one
        if ((filter_type === 'userbase' && filter[field] !== 0) || ((filter_type !== 'sdk' && filter_type !== 'sdkCategory') && oldFilter.status !== filter.status)) {
          if (filter_type === 'userbase' && filter[field] !== 0) {
            filter[filter_type] = $scope.engagementOptions(`${filter.status}-0-8`);
            const customName = `${$scope.intToUserbase(filter[filter_type].minValue)}-${$scope.intToUserbase(filter[filter_type].maxValue)}`;
            filterService.addFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type), $scope.complexFilterDisplayText(filter_type, filter_operation, filter), false, customName);
          } else { // is location filter
            filter[filter_type] = null;
          }
          if (oldFilter[filter_type]) {
            filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(oldFilter, filter_type));
          }
        } else if (oldFilter[filter_type]) { // is sdk filter and has sdk selected
          if (field === 'date' && $scope.hasCustomDateRange(filter)) {
            filter.dateRange = { from: new Date(), until: new Date() };
            filterService.changeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(oldFilter, filter_type), { [field]: filter[field], dateRange: filter.dateRange }, $scope.complexFilterDisplayText(filter_type, filter_operation, filter));
          } else {
            filterService.changeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(oldFilter, filter_type), { [field]: filter[field] }, $scope.complexFilterDisplayText(filter_type, filter_operation, filter));
          }
        }
        $scope.updateSdkModalWidth();
        $scope.checkDateRanges();
      };

      $scope.removeComplexFilter = function(filter_type, filter_operation, filter) {
        const index = $rootScope.complexFilters[filter_type][filter_operation].indexOf(filter);
        if (index > -1) {
          const filter = $rootScope.complexFilters[filter_type][filter_operation][index];
          if (filter[filter_type]) {
            filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type));
          }
          $rootScope.complexFilters[filter_type][filter_operation].splice(index, 1);
          if (!$rootScope.complexFilters[filter_type][filter_operation].length) $scope.addComplexFilter(filter_type, filter_operation);
        }
        $scope.updateSdkModalWidth();
        $scope.checkDateRanges();
      };

      $scope.removeComplexNameFilter = function(filter_type, filter_operation, index) {
        const filter = $rootScope.complexFilters[filter_type][filter_operation][index];
        filterService.removeFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type));
        $rootScope.complexFilters[filter_type][filter_operation][index][filter_type] = null;
      };

      $scope.sdkSelectEvents = {
        onSelectionChanged () {
          filterService.clearAllSdkCategoryTags();
          ['and', 'or'].forEach((filterOperation) => {
            $rootScope.complexFilters.sdkCategory[filterOperation].forEach((filter) => {
              if (filter.sdkCategory) {
                filterService.addFilter($scope.complexFilterKey('sdkCategory', filterOperation), $scope.filterToTag(filter, 'sdkCategory'), $scope.complexFilterDisplayText('sdkCategory', filterOperation, filter), false, filter.sdkCategory.name);
              }
            });
          });
        },
      };

      $scope.selectedAndSdk = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'and');
      };

      $scope.selectedOrSdk = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'sdk', 'or');
      };

      $scope.selectedAndSdkCategory = function (category, index) {
        const object = _.cloneDeep(category);
        object.selectedSdks = category.sdks.map(sdk => ({ id: sdk.id }));
        delete object.sdks;
        $scope.selectedComplexName(object, index, 'sdkCategory', 'and');
      };

      $scope.selectedOrSdkCategory = function (category, index) {
        const object = _.cloneDeep(category);
        object.selectedSdks = category.sdks.map(sdk => ({ id: sdk.id }));
        delete object.sdks;
        $scope.selectedComplexName(object, index, 'sdkCategory', 'or');
      };

      $scope.selectedAndLocation = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'location', 'and');
      };

      $scope.selectedOrLocation = function ($item) {
        $scope.selectedComplexName($item.originalObject, this.$parent.$index, 'location', 'or');
      };

      $scope.selectedComplexName = function(object, index, filter_type, filter_operation) {
        if (typeof object === 'string' || object instanceof String) {
          object = $scope.findAppStore(object);
        }

        $rootScope.complexFilters[filter_type][filter_operation][index][filter_type] = object;
        const filter = $rootScope.complexFilters[filter_type][filter_operation][index];
        filterService.addFilter($scope.complexFilterKey(filter_type, filter_operation), $scope.filterToTag(filter, filter_type), $scope.complexFilterDisplayText(filter_type, filter_operation, filter), false, object.name);
      };

      $scope.filterToTag = function(filter, filter_type) {
        switch (filter_type) {
          case 'sdk':
            return {
              id: filter.sdk.id, status: filter.status, date: filter.date, name: filter.sdk.name, dateRange: filter.dateRange,
            };
          case 'sdkCategory':
            return {
              id: filter.sdkCategory.id, status: filter.status, date: filter.date, name: filter.sdkCategory.name, selectedSdks: $scope.checkFilterSelectedSdks(filter), dateRange: filter.dateRange,
            };
          case 'location':
            return {
              id: filter.location.id, status: filter.status, name: filter.location.name, state: filter.state,
            };
          case 'userbase':
            if (filter.status === 0) {
              return { id: filter.userbase.id, status: filter.status, name: filter.userbase.name };
            }
            return { id: filter.userbase.options.id, status: filter.status, name: filter.userbase.name };
        }
      };

      $scope.checkFilterSelectedSdks = function (filter) {
        const categorySdkCount = $rootScope.sdkCategories[filter.sdkCategory.name].sdks.length;
        const filterSdkCount = filter.sdkCategory.selectedSdks.length;
        if (filterSdkCount === categorySdkCount) {
          return 'all';
        }
        return filter.sdkCategory.selectedSdks.map(sdk => sdk.id);
      };

      $scope.checkTagSelectedSdks = function (tag) {
        if (tag.selectedSdks === 'all') {
          return $rootScope.sdkCategories[tag.name].sdks.map(sdk => ({ id: sdk.id }));
        }
        return tag.selectedSdks.map(id => ({ id }));
      };

      $scope.tagToFilter = function(tag, filter_type) {
        switch (filter_type) {
          case 'sdk':
            return {
              status: tag.status, date: tag.date, dateRange: tag.dateRange, sdk: { id: tag.id, name: tag.name },
            };
          case 'sdkCategory':
            return {
              status: tag.status, date: tag.date, dateRange: tag.dateRange, sdkCategory: { id: tag.id, name: tag.name, selectedSdks: $scope.checkTagSelectedSdks(tag) },
            };
          case 'location':
            return { status: tag.status, location: { id: tag.id, name: tag.name }, state: tag.state };
          case 'userbase':
            // if (tag.status === 0) {
              return { status: tag.status, userbase: { id: tag.id, name: tag.name } };
            // }
            // return { status: tag.status, userbase: $scope.engagementOptions(tag.id) };
        }
      };

      $scope.filterIsEqualToTag = function(filter, tag, filter_type) {
        return filter.status === tag.value.status && filter[filter_type].id === tag.value.id && filter.date === tag.value.date && filter.state === tag.value.state;
      };

      $scope.filterIsEqualToFilter = function(filter1, filter2, filter_type) {
        return filter1.status === filter2.status && filter1[filter_type].id === filter2[filter_type].id && filter1.date === filter2.date && filter1.state === filter2.state;
      };

      $scope.$watchCollection('$root.tags', () => {
        if ($rootScope.tags) {
          Object.keys($rootScope.complexFilters).forEach((filterType) => {
            const filters = $rootScope.complexFilters[filterType];
            Object.keys(filters).forEach((filterOperation) => {
              const opFilters = $rootScope.complexFilters[filterType][filterOperation];
              for (let index = 0; index < opFilters.length; index++) {
                let found = false;
                const filter = opFilters[index];
                if (filter[filterType]) {
                  $rootScope.tags.forEach((tag) => {
                    const targetParameter = $scope.complexFilterKey(filterType, filterOperation);
                    if (targetParameter === tag.parameter && $scope.filterIsEqualToTag(filter, tag, filterType)) {
                      found = true;
                    }
                  });
                }

                if (!found) {
                  opFilters.splice(index, 1);
                  index--;
                }
              }
              if (!opFilters.length) $scope.addBlankComplexFilter(filterType, filterOperation);
            });
          });
        }
        $scope.listButtonDisabled = true;
        $scope.checkDateRanges();
        $scope.updateSdkModalWidth();
      });

      $scope.removedTag = function(tag) {
        let model;
        switch (tag.parameter) {
          case 'downloads':
            model = $rootScope.downloadsModel;
            break;
          case 'categories':
            model = $rootScope.categoryModel;
            break;
          case 'mobilePriority':
            model = $rootScope.mobilePriorityModel;
            break;
          case 'userBases':
            model = $rootScope.userbaseModel;
            break;
          default:
            return;
        }
        for (let i = model.length - 1; i >= 0; i--) {
          if (model[i].id === tag.value) {
            model.splice(i, 1);
          }
        }
      };

      $scope.rebuildFromURLParam = function(key, arrayItem) {
        switch (key) {
          case 'sdkFiltersAnd':
            $scope.addComplexFilter('sdk', 'and', $scope.tagToFilter(arrayItem, 'sdk'));
            break;
          case 'sdkFiltersOr':
            $scope.addComplexFilter('sdk', 'or', $scope.tagToFilter(arrayItem, 'sdk'));
            break;
          case 'sdkCategoryFiltersAnd':
            $scope.addComplexFilter('sdkCategory', 'and', $scope.tagToFilter(arrayItem, 'sdkCategory'));
            break;
          case 'sdkCategoryFiltersOr':
            $scope.addComplexFilter('sdkCategory', 'or', $scope.tagToFilter(arrayItem, 'sdkCategory'));
            break;
          case 'locationFiltersOr':
            $scope.addComplexFilter('location', 'or', $scope.tagToFilter(arrayItem, 'location'));
            break;
          case 'locationFiltersAnd':
            $scope.addComplexFilter('location', 'and', $scope.tagToFilter(arrayItem, 'location'));
            break;
          case 'userbaseFiltersOr':
            $scope.addComplexFilter('userbase', 'or', $scope.tagToFilter(arrayItem, 'userbase'));
            break;
        }
        if (['categories', 'downloads', 'mobilePriority', 'userBases'].includes(key)) {
          $scope.addDropdownFilter(key, arrayItem);
        }
      };

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function(isTablePageChange) {
        const routeParams = $location.search();
        const urlParams = $location.url().split('/search')[1]; // If url params not provided
        /* Compile Object with All Filters from Params */
        if (routeParams.app) var appParams = JSON.parse(routeParams.app);
        if (routeParams.company) var companyParams = JSON.parse(routeParams.company);
        if (routeParams.platform) var platform = JSON.parse(routeParams.platform);

        $scope.filters = { company: companyParams, platform, app: appParams };

        const allParams = appParams || [];
        for (const attribute in companyParams) {
          allParams[attribute] = companyParams[attribute];
        }

        const checkPlatform = $scope.checkPlatformPromise(platform.appPlatform);
        checkPlatform.then(() => {
          searchCtrl.appPlatform.platform = window.APP_PLATFORM;
          $rootScope.tags = [];
          $scope.rebuildFiltersFromUrl(allParams);
          $rootScope.dashboardSearchButtonDisabled = true;
          $rootScope.searchError = false;
          const submitSearchStartTime = new Date().getTime();
          $scope.queryInProgress = true;
          return $http({
            method: 'POST',
            url: `${API_URI_BASE}api/filter_${window.APP_PLATFORM}_apps${urlParams}`,
          })
            .success((data) => {
              $scope.listButtonDisabled = false;
              searchCtrl.apps = data.results;
              searchCtrl.numApps = data.resultsCount;
              $rootScope.numApps = data.resultsCount;
              $rootScope.dashboardSearchButtonDisabled = false;
              searchCtrl.currentPage = data.pageNum;
              searchCtrl.updateCSVUrl();
              if (!isTablePageChange) { searchCtrl.resultsSortCategory = 'name'; } // if table page change, set default sort
              if (!isTablePageChange) { searchCtrl.resultsOrderBy = 'asc'; } // if table page change, set default order

              const submitSearchEndTime = new Date().getTime();
              const submitSearchElapsedTime = submitSearchEndTime - submitSearchStartTime;

              if (data.pageNum == '1') { $scope.trackFilterQueryAnalytics(submitSearchElapsedTime, data.resultsCount); }
            })
            .error((data, status) => {
              $rootScope.dashboardSearchButtonDisabled = false;
              $rootScope.searchError = true;
              mixpanel.track(
                'Filter Query Failed',
                {
                  tags: $rootScope.tags,
                  errorMessage: data,
                  errorStatus: status,
                  platform: window.APP_PLATFORM,
                },
              );
            });
        });
      };

      $scope.rebuildFiltersFromUrl = function (urlParams) {
        /* Rebuild Filters Array from URL Params */
        for (var key in urlParams) {
          const value = urlParams[key];
          if (Array.isArray(value)) {
            value.forEach((arrayItem) => {
              if (arrayItem !== null) $rootScope.tags.push(searchService.searchFilters(key, arrayItem));
              $scope.rebuildFromURLParam(key, arrayItem);
            });
          } else {
            $rootScope.tags.push(searchService.searchFilters(key, value));
          }
        }
      };

      $scope.trackFilterQueryAnalytics = function (elapsedTime, resultsCount) {
        /* -------- Mixpanel Analytics Start -------- */
        const searchQueryPairs = {};
        const searchQueryFields = [];
        searchQueryPairs.locationFilter = false;

        let categoriesPresent = false;
        const categories = [];
        let sdksPresent = false;
        const sdks = [];
        let sdkCategoriesPresent = false;
        const sdkCategories = [];

        $rootScope.tags.forEach((tag) => {
          searchQueryFields.push(tag.parameter);

          // Tracking date filters
          if (tag.value.date === '7') {
            mixpanel.track(
              'Custom Date Range Used',
              { dateRange: tag.value.dateRange },
            );
          } else if (parseInt(tag.value.date) >= 8) {
            mixpanel.track(
              'Old Date Filter Used',
              { date: tag.value.date },
            );
          }
          if (tag.parameter === 'categories') {
            categoriesPresent = true;
            categories.push(tag.value);
          } else if (['locationFiltersOr', 'locationFiltersAnd'].includes(tag.parameter)) {
            searchQueryPairs.locationFilter = true;
          } else if (['sdkFiltersAnd', 'sdkFiltersOr'].includes(tag.parameter)) {
            sdksPresent = true;
            sdks.push(tag.value.name);
          } else if (['sdkCategoryFiltersAnd', 'sdkCategoryFiltersOr'].includes(tag.parameter)) {
            sdkCategoriesPresent = true;
            sdkCategories.push(tag.value.name);
          } else {
            searchQueryPairs[tag.parameter] = tag.value;
          }
        });
        searchQueryPairs.tags = searchQueryFields;
        searchQueryPairs.numOfApps = resultsCount;
        searchQueryPairs.elapsedTimeInMS = elapsedTime;
        searchQueryPairs.platform = window.APP_PLATFORM;
        if (categoriesPresent) searchQueryPairs.categories = categories;
        if (sdksPresent) searchQueryPairs.sdks = sdks;
        if (sdkCategoriesPresent) searchQueryPairs.sdkCategories = sdkCategories;

        mixpanel.track(
          'Filter Query Successful',
          searchQueryPairs,
        );
      };

      $scope.checkPlatformPromise = function (newPlatform) {
        return $q((resolve, reject) => {
          if (window.APP_PLATFORM !== newPlatform) {
            window.APP_PLATFORM = newPlatform;
            apiService.getSdkCategories().success((data) => {
              $rootScope.sdkCategories = data;
              resolve();
            });
          } else {
            resolve();
          }
        });
      };

      $scope.filterResultsExported = function () {
        mixpanel.track('Filter Results Exported', {
          numApps: $rootScope.numApps,
          platform: window.APP_PLATFORM,
        });
      };

      // When main Dashboard search button is clicked
      searchCtrl.submitSearch = function() {
        if ($scope.invalidDateRanges) {
          loggitService.logError('Invalid date range(s)');
        } else {
          $scope.rowSort = null;
          const urlParams = searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, 'name', 'asc', $scope.list);
          $location.url(`/search?${urlParams}`);
          searchCtrl.loadTableData();
        }
      };

      searchCtrl.submitPageChange = function() {
        const currentPage = searchCtrl.currentPage;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('Explore Table Paged Through', {
          page: currentPage,
          tags: $rootScope.tags,
          appPlatform: window.APP_PLATFORM,
        });
        /* -------- Mixpanel Analytics End -------- */

        const urlParams = searchService.queryStringParameters($rootScope.tags, currentPage, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy, $scope.list);
        $location.url(`/search?${urlParams}`);
        searchCtrl.loadTableData(true);
        const start = (currentPage - 1) * $rootScope.numPerPage;
        return start + $rootScope.numPerPage;
      };

      // Saved searches

      savedSearchApiService.getSavedSearches().success((data) => {
        searchCtrl.savedSearches = {};
        searchCtrl.searchName = '';
        data.forEach((search) => {
          searchCtrl.savedSearches[search.id] = search;
        });
        searchCtrl.hasSearches = checkSearches();
      });

      function checkSearches () {
        return Object.keys(searchCtrl.savedSearches).length > 0;
      }

      searchCtrl.onSavedSearchChange = function(id) {
        $rootScope.tags = [];
        $rootScope.complexFilters = {
          sdk: { or: [{ status: '0', date: '0' }], and: [{ status: '0', date: '0' }] },
          sdkCategory: { or: [{ status: '0', date: '0' }], and: [{ status: '0', date: '0' }] },
          location: { or: [{ status: '0', state: '0' }], and: [{ status: '0', state: '0' }] },
          userbase: { or: [{ status: '0' }], and: [{ status: '0' }] },
        };
        $scope.emptyApps();
        const savedSearch = searchCtrl.savedSearches[id];
        $location.url(`/search?${savedSearch.search_params}`);
        $scope.rowSort = null;
        searchCtrl.loadTableData();

        /* -------- Mixpanel Analytics Start -------- */
        const slacktivityData = {
          title: 'Previous Saved Search Loaded',
          fallback: 'Previous Saved Search Loaded',
          color: '#FFD94D',
          Name: savedSearch.name,
          Parameters: savedSearch.search_params,
        };
        slacktivity.notifySlack(slacktivityData);
        mixpanel.track('Previous Saved Search Loaded', {
          name: savedSearch.name,
          parameters: savedSearch.search_params,
        });
        /* -------- Mixpanel Analytics End -------- */
      };

      searchCtrl.createSavedSearch = function(name) {
        if ($scope.invalidDateRanges) {
          loggitService.logError('Invalid date range(s)');
        } else {
          const queryString = searchService.queryStringParameters($rootScope.tags, 1, 100);
          savedSearchApiService.createSavedSearch(name, queryString)
            .success((data) => {
              searchCtrl.savedSearches[data.id] = data;
              searchCtrl.searchName = '';
              searchCtrl.hasSearches = checkSearches();
              savedSearchApiService.toast('search-create-success');

              /* -------- Analytics Start -------- */
              const slacktivityData = {
                title: 'New Saved Search Created',
                fallback: 'New Saved Search Created',
                color: '#FFD94D',
                Name: data.name,
                Parameters: data.search_params,
              };
              slacktivity.notifySlack(slacktivityData);
              mixpanel.track('New Saved Search Created', {
                name: data.name,
                parameters: data.search_params,
              });
            /* -------- Analytics End -------- */
            })
            .error((error) => {
              savedSearchApiService.toast('search-create-failure');
            });
        }
      };

      searchCtrl.setCurrentSearchId = function(id, $event) {
        $event.stopPropagation();
        const modalInstance = $uibModal.open({
          animation: true,
          ariaLabelledBy: 'searchDeleteModalTitle',
          ariaDescribedBy: 'searchDeleteModalBoday',
          template: require('../../views/modals/search-delete.html'),
          // templateUrl: 'search-delete.html',
          controller: 'ModalInstanceCtrl',
          controllerAs: '$ctrl',
          resolve: {
            id () {
              return id;
            },
          },
        });

        modalInstance.result.then((id) => {
          searchCtrl.deleteSavedSearch(id);
        });
      };

      searchCtrl.deleteSavedSearch = function(id) {
        savedSearchApiService.deleteSavedSearch(id)
          .success((data) => {
            delete searchCtrl.savedSearches[data.id];
            savedSearchApiService.toast('search-delete-success');
            searchCtrl.hasSearches = Object.keys(searchCtrl.savedSearches).length > 0;

            /* -------- Mixpanel Analytics Start -------- */
            const slacktivityData = {
              title: 'Saved Search Deleted',
              fallback: 'Saved Search Deleted',
              color: '#FFD94D',
              Name: data.name,
              Parameters: data.search_params,
            };
            slacktivity.notifySlack(slacktivityData);
            mixpanel.track('Saved Search Deleted', {
              name: data.name,
              parameters: data.search_params,
            });
            /* -------- Mixpanel Analytics End -------- */
          })
          .error((error) => {
            savedSearchApiService.toast('search-delete-failure');
          });
      };

      // When orderby/sort arrows on dashboard table are clicked
      searchCtrl.sortApps = function(category, order) {
        const sign = order === 'desc' ? '-' : '';
        $scope.rowSort = sign + category;

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('Explore Table Sorting Changed', {
          category,
          order,
          appPlatform: window.APP_PLATFORM,
        });
        /* -------- Mixpanel Analytics End -------- */
        const firstPage = 1;
        $rootScope.dashboardSearchButtonDisabled = true;
        const urlParams = searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, category, order);
        $location.url(`/search?${urlParams}`);
        apiService.searchRequestPost($rootScope.tags, firstPage, $rootScope.numPerPage, category, order, searchCtrl.appPlatform.platform)
          .success((data) => {
            $scope.queryInProgress = false;
            searchCtrl.apps = data.results;
            searchCtrl.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            searchCtrl.currentPage = 1;
            searchCtrl.resultsSortCategory = category;
            searchCtrl.resultsOrderBy = order;
            searchCtrl.updateCSVUrl();
          })
          .error(() => {
            $scope.queryInProgress = false;
            $rootScope.dashboardSearchButtonDisabled = false;
          });
      };

      // Computes class for last updated data in Last Updated column rows
      searchCtrl.getLastUpdatedDaysClass = function(lastUpdatedDays) {
        return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
      };

      searchCtrl.updateCSVUrl = function() {
        searchCtrl.csvUrl = `${API_URI_BASE}api/search/export_to_csv.csv${$location.url().split('/search')[1]}&access_token=${authToken.get()}`;
      };

      $scope.getList = function() {
        const routeParams = $location.search();
        if (!routeParams.listId) return;
        listApiService.getList(routeParams.listId).success((data) => {
          $scope.list = data;
        });
      };

      $scope.updateList = function() {
        const routeParams = $location.search();
        listApiService.updateList(routeParams.listId, $scope.filters)
          .success((data) => {
            $scope.notify('saved-list-success');
          }).error(() => {
            $scope.notify('saved-list-error');
          });
      };

      $scope.notify = function(type) {
        listApiService.listNotify(type);
      };

      /* Only hit api if query string params are present */
      if ($location.url().split('/search')[1]) {
        apiService.getSdkCategories().success((data) => {
          $rootScope.sdkCategories = data;
          searchCtrl.loadTableData();
        });
      }

      $scope.getAppStores = function() {
        $http({
          method: 'get',
          url: $scope.locationAutocompleteUrl(1),
        })
          .success((data) => {
            $scope.availableAppStores = data.results;
          });
      };

      $scope.findAppStore = function(countryCode) {
        for (let i = 0; i < $scope.availableAppStores.length; i++) {
          if ($scope.availableAppStores[i].id === countryCode) {
            return $scope.availableAppStores[i];
          }
        }
        return null;
      };

      searchCtrl.clearFilters = function () {
        const numFilters = $rootScope.tags.length;
        mixpanel.track('Filters Cleared', {
          'Number of Filters': numFilters,
        });
        $rootScope.tags = [];
        $rootScope.categoryModel = [];
        $rootScope.downloadsModel = [];
        $rootScope.userbaseModel = [];
        $rootScope.mobilePriorityModel = [];
      };

      searchCtrl.exploreItemClicked = function (item, type) {
        mixpanel.track('Explore Item Clicked', {
          name: item.name,
          id: item.id,
          type,
        });
      };

      $scope.getList();
      $scope.getAppStores();
    },
  ]);
