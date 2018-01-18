import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import 'components/top-header/top-header.directive.js';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$scope', '$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService', 'slacktivity', 'searchService', '$window', 'pageTitleService',
    function($scope, $rootScope, customSearchService, $httpParamSerializer, $location, listApiService, slacktivity, searchService, $window, pageTitleService) {
      const customSearchCtrl = this;
      customSearchCtrl.platform = window.APP_PLATFORM; // default
      customSearchCtrl.newSearch = false;

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {
        pageTitleService.setTitle('MightySignal - Search');
        customSearchCtrl.queryInProgress = true;

        const routeParams = $location.search();
        customSearchService.customSearch(routeParams.platform, routeParams.query, routeParams.page, routeParams.numPerPage, routeParams.sortBy, routeParams.orderBy)
          .success((data) => {
            customSearchCtrl.apps = data.appData;
            customSearchCtrl.appNum = data.appData.length;
            customSearchCtrl.numApps = data.totalAppsCount;
            customSearchCtrl.numPerPage = data.numPerPage;
            customSearchCtrl.changeAppPlatform(routeParams.platform);
            customSearchCtrl.searchInput = routeParams.query;
            customSearchCtrl.currentPage = data.page;
            $rootScope.apps = customSearchCtrl.apps;
            $rootScope.numApps = customSearchCtrl.numApps;
            customSearchCtrl.queryInProgress = false;

            if (customSearchCtrl.newSearch) {
              mixpanel.track('Custom Search Loaded', {
                Query: customSearchCtrl.searchInput,
                Platform: customSearchCtrl.platform,
                'Results Count': customSearchCtrl.numApps,
              });
            }
          })
          .error(() => {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
            customSearchCtrl.queryInProgress = false;
          });
      };

      if ($location.search().platform) {
        customSearchCtrl.loadTableData();
      }


      // When orderby/sort arrows on dashboard table are clicked
      customSearchCtrl.sortApps = function(category, order) {
        customSearchCtrl.newSearch = false;
        const sign = order === 'desc' ? '-' : '';
        customSearchCtrl.rowSort = sign + category;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('Custom Search Table Sorting Changed', {
          category,
          order,
          appPlatform: window.APP_PLATFORM,
          Query: customSearchCtrl.searchInput,
        });
        /* -------- Mixpanel Analytics End -------- */
        const routeParams = $location.search();
        routeParams.orderBy = order;
        routeParams.sortBy = category;
        const targetUrl = (customSearchCtrl.platform === 'iosSdks' || customSearchCtrl.platform === 'androidSdks') ? `/search/sdk/${customSearchCtrl.platform}?` : '/search/custom?';
        $location.url(targetUrl + $httpParamSerializer(routeParams));
        customSearchCtrl.loadTableData();
      };

      customSearchCtrl.changeAppPlatform = function(platform) {
        customSearchCtrl.platform = platform;
      };

      customSearchCtrl.onPageChange = function(nextPage) {
        customSearchCtrl.submitSearch(nextPage, true);
        mixpanel.track('Custom Search Table Paged Through', {
          'Target Page': nextPage,
          Query: customSearchCtrl.searchInput,
        });
      };

      customSearchCtrl.submitSearch = function(newPageNum, keepSort) {
        customSearchCtrl.newSearch = typeof newPageNum === 'undefined';
        if (typeof newPageNum === 'undefined') {
          customSearchCtrl.rowSort = null;
        }
        const routeParams = $location.search();
        const payload = {
          query: customSearchCtrl.searchInput,
          platform: customSearchCtrl.platform,
          page: newPageNum || 1,
          numPerPage: 30,
        };
        if (routeParams.sortBy && keepSort) {
          payload.sortBy = routeParams.sortBy;
          payload.orderBy = routeParams.orderBy;
        }
        const targetUrl = (customSearchCtrl.platform === 'iosSdks' || customSearchCtrl.platform === 'androidSdks') ? `/search/sdk/${customSearchCtrl.platform}?` : '/search/custom?';

        if (customSearchCtrl.platform === 'androidSdks' || customSearchCtrl.platform === 'iosSdks') {
          // Set URL & process/redirect to SDK Search Ctrl
          $window.location.href = `#${targetUrl}${$httpParamSerializer(payload)}`;

          mixpanel.track('SDK Custom Search', {
            query: customSearchCtrl.searchInput,
            platform: customSearchCtrl.platform.split('Sdks')[0], // grabs 'android' or 'ios'
          });
        } else {
          // Set URL & process request using Custom Search Ctrl
          $location.url(targetUrl + $httpParamSerializer(payload));
          customSearchCtrl.loadTableData();
        }
      };

      customSearchCtrl.searchPlaceholderText = function() {
        if (customSearchCtrl.platform === 'ios') {
          return 'Search for iOS app or company';
        } else if (customSearchCtrl.platform === 'android') {
          return 'Search for Android app or company';
        } else if (customSearchCtrl.platform === 'androidSdks') {
          return 'Search for Android SDKs';
        } else if (customSearchCtrl.platform === 'iosSdks') {
          return 'Search for iOS SDKs';
        }
      };

      $scope.$watch('customSearchCtrl.platform', () => {
        customSearchCtrl.apps = [];
        customSearchCtrl.appNum = 0;
        customSearchCtrl.numApps = 0;
        customSearchCtrl.queryInProgress = false;
        if (customSearchCtrl.searchInput && customSearchCtrl.searchInput !== '') customSearchCtrl.submitSearch();
      });

      customSearchCtrl.getLastUpdatedDaysClass = function(lastUpdatedDays) {
        return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
      };

      customSearchCtrl.addSelectedTo = function(list, selectedApps) {
        listApiService.addSelectedTo(list, selectedApps).success(() => {
          customSearchCtrl.notify('add-selected-success');
          $rootScope.selectedAppsForList = [];
        }).error(() => {
          customSearchCtrl.notify('add-selected-error');
        });
        $rootScope.addSelectedToDropdown = ''; // Resets HTML select on view to default option
      };

      customSearchCtrl.notify = function(type) {
        listApiService.listAddNotify(type);
      };

      customSearchCtrl.appsDisplayedCount = function() {
        const lastPageMaxApps = customSearchCtrl.numPerPage * customSearchCtrl.currentPage;
        const baseAppNum = customSearchCtrl.numPerPage * (customSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > customSearchCtrl.numApps) {
          return `${baseAppNum.toLocaleString()} - ${customSearchCtrl.numApps.toLocaleString()}`;
        }
        return `${baseAppNum.toLocaleString()} - ${lastPageMaxApps.toLocaleString()}`;
      };

      customSearchCtrl.customSearchLinkClicked = function (type, item) {
        mixpanel.track('Custom Search Link Clicked', {
          type,
          id: item.id,
          name: item.name,
          platform: customSearchCtrl.platform,
          query: customSearchCtrl.searchInput,
        });
      };
    },
  ]);
