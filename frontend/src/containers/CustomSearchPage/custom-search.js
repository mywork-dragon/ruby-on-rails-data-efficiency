import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import 'components/top-header/top-header.directive.js';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$scope', '$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService', 'slacktivity', 'searchService', '$window', 'pageTitleService', 'bugsnagHelper', '$state',
    function($scope, $rootScope, customSearchService, $httpParamSerializer, $location, listApiService, slacktivity, searchService, $window, pageTitleService, bugsnagHelper, $state) {
      const customSearchCtrl = this;
      customSearchCtrl.searchItem = 'app'; // default
      customSearchCtrl.newSearch = false;

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {
        pageTitleService.setTitle('MightySignal - Search');
        customSearchCtrl.queryInProgress = true;

        const routeParams = $location.search();
        customSearchService.customSearch(customSearchCtrl.searchItem, routeParams.query, routeParams.page, routeParams.numPerPage, routeParams.sortBy, routeParams.orderBy)
          .success((data) => {
            customSearchCtrl.apps = data.appData.map(x => ({ ...x, publisher: { ...x.publisher, platform: x.platform } }));
            customSearchCtrl.appNum = data.appData.length;
            customSearchCtrl.numApps = data.totalAppsCount;
            customSearchCtrl.numPerPage = data.numPerPage;
            customSearchCtrl.searchInput = routeParams.query;
            customSearchCtrl.searchItem = routeParams.item;
            customSearchCtrl.currentPage = data.page;
            $rootScope.apps = customSearchCtrl.apps;
            $rootScope.numApps = customSearchCtrl.numApps;
            customSearchCtrl.queryInProgress = false;

            if (customSearchCtrl.newSearch) {
              mixpanel.track('Custom Search Loaded', {
                Query: customSearchCtrl.searchInput,
                'Results Count': customSearchCtrl.numApps,
              });
            }
          })
          .error(() => {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
            customSearchCtrl.queryInProgress = false;
            bugsnagHelper('Failed Custom Search', 'Failed Custom Search', { routeParams });
          });
      };

      if ($location.search().item === 'app') {
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
          Query: customSearchCtrl.searchInput,
        });
        /* -------- Mixpanel Analytics End -------- */
        const routeParams = $location.search();
        routeParams.orderBy = order;
        routeParams.sortBy = category;
        const targetUrl = customSearchCtrl.searchItem === 'sdk' ? '/search/sdks?' : '/search/custom?';
        $location.url(targetUrl + $httpParamSerializer(routeParams));
        customSearchCtrl.loadTableData();
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
          item: customSearchCtrl.searchItem,
          page: newPageNum || 1,
          numPerPage: 30,
        };
        if (routeParams.sortBy && keepSort) {
          payload.sortBy = routeParams.sortBy;
          payload.orderBy = routeParams.orderBy;
        }

        const targetUrl = (customSearchCtrl.searchItem === 'sdk') ? '/search/sdks?' : '/search/custom?';

        if (customSearchCtrl.searchItem === 'sdk') {
          // Set URL & process/redirect to SDK Search Ctrl
          $window.location.href = `#${targetUrl}${$httpParamSerializer(payload)}`;

          mixpanel.track('SDK Custom Search', {
            query: customSearchCtrl.searchInput,
          });
        } else {
          // Set URL & process request using Custom Search Ctrl
          $location.url(targetUrl + $httpParamSerializer(payload));
          customSearchCtrl.loadTableData();
        }
      };

      customSearchCtrl.searchPlaceholderText = function() {
        if (customSearchCtrl.searchItem === 'app') {
          return 'Search for app or company';
        } else if (customSearchCtrl.searchItem === 'sdk') {
          return 'Search for SDKs';
        }
      };

      $scope.$watch('customSearchCtrl.searchItem', () => {
        customSearchCtrl.apps = [];
        customSearchCtrl.appNum = 0;
        customSearchCtrl.numApps = 0;
        customSearchCtrl.queryInProgress = false;
        if (customSearchCtrl.searchInput && customSearchCtrl.searchInput !== '') customSearchCtrl.submitSearch();
      });

      $scope.$on('$locationChangeSuccess', function () {
        if ($state.current.name === 'custom-search') {
          customSearchCtrl.searchItem = $location.search().item;
          const query = $location.search().query;
          if (query !== customSearchCtrl.searchInput) {
            customSearchCtrl.searchInput = $location.search().query;
            customSearchCtrl.loadTableData();
          }
        }
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
          platform: item.platform,
          query: customSearchCtrl.searchInput,
        });
      };
    },
  ]);
