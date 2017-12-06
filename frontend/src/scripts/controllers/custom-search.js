import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import 'shared/top-header/top-header.directive.js';
import 'shared/list-create/list-create.directive';
import 'shared/list-delete/list-delete.directive';
import 'shared/list-delete-selected/list-delete-selected.directive';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$scope', '$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService', "slacktivity", "searchService", "$window", "pageTitleService",
    function($scope, $rootScope, customSearchService, $httpParamSerializer, $location, listApiService, slacktivity, searchService, $window, pageTitleService) {
      var customSearchCtrl = this;
      customSearchCtrl.platform = window.APP_PLATFORM; // default
      customSearchCtrl.newSearch = false;

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {
        pageTitleService.setTitle("MightySignal - Search")
        customSearchCtrl.queryInProgress = true;

        var routeParams = $location.search();
        customSearchService.customSearch(routeParams.platform, routeParams.query, routeParams.page, routeParams.numPerPage, routeParams.sortBy, routeParams.orderBy)
          .success(function(data) {
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
              mixpanel.track("Custom Search Loaded", {
                "Query": customSearchCtrl.searchInput,
                "Platform": customSearchCtrl.platform,
                "Results Count": customSearchCtrl.numApps
              })
            }
          })
          .error(function(data) {
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
        customSearchCtrl.newSearch = false
        const sign = order == 'desc' ? '-' : ''
        customSearchCtrl.rowSort = sign + category
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Custom Search Table Sorting Changed", {
            "category": category,
            "order": order,
            "appPlatform": window.APP_PLATFORM,
            "Query": customSearchCtrl.searchInput
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        var routeParams = $location.search();
        routeParams.orderBy = order
        routeParams.sortBy = category
        var targetUrl = (customSearchCtrl.platform == 'iosSdks' || customSearchCtrl.platform == 'androidSdks') ? '/search/sdk/' + customSearchCtrl.platform + '?' : '/search/custom?';
        $location.url(targetUrl + $httpParamSerializer(routeParams));
        customSearchCtrl.loadTableData();
      };

      customSearchCtrl.changeAppPlatform = function(platform) {
        customSearchCtrl.platform = platform;
      };

      customSearchCtrl.onPageChange = function(nextPage) {
        customSearchCtrl.submitSearch(nextPage, true);
        mixpanel.track("Custom Search Table Paged Through", {
          "Target Page": nextPage,
          "Query": customSearchCtrl.searchInput
        })
      };

      customSearchCtrl.submitSearch = function(newPageNum, keepSort) {
        customSearchCtrl.newSearch = typeof newPageNum == 'undefined' ? true : false;
        if (typeof newPageNum == 'undefined') {
          customSearchCtrl.rowSort = null
        }
        var routeParams = $location.search();
        var payload = {
          query: customSearchCtrl.searchInput,
          platform: customSearchCtrl.platform,
          page: newPageNum || 1,
          numPerPage: 30
        };
        if (routeParams.sortBy && keepSort) {
          payload.sortBy = routeParams.sortBy
          payload.orderBy = routeParams.orderBy
        }
        var targetUrl = (customSearchCtrl.platform == 'iosSdks' || customSearchCtrl.platform == 'androidSdks') ? '/search/sdk/' + customSearchCtrl.platform + '?' : '/search/custom?';

        if (customSearchCtrl.platform == 'androidSdks' || customSearchCtrl.platform == 'iosSdks') {

          // Set URL & process/redirect to SDK Search Ctrl
          $window.location.href = '#' + targetUrl + $httpParamSerializer(payload);

          mixpanel.track(
            "SDK Custom Search", {
              "query": customSearchCtrl.searchInput,
              "platform": customSearchCtrl.platform.split('Sdks')[0] // grabs 'android' or 'ios'
            }
          );

        } else {

          // Set URL & process request using Custom Search Ctrl
          $location.url(targetUrl + $httpParamSerializer(payload));
          customSearchCtrl.loadTableData();
        }
      };

      customSearchCtrl.searchPlaceholderText = function() {
        if(customSearchCtrl.platform == 'ios') {
          return 'Search for iOS app or company';
        } else if(customSearchCtrl.platform == 'android') {
          return 'Search for Android app or company';
        } else if(customSearchCtrl.platform == 'androidSdks') {
          return 'Search for Android SDKs';
        } else if(customSearchCtrl.platform == 'iosSdks') {
          return 'Search for iOS SDKs';
        }
      };

      $scope.$watch('customSearchCtrl.platform', function() {
        customSearchCtrl.apps = [];
        customSearchCtrl.appNum = 0;
        customSearchCtrl.numApps = 0;
        customSearchCtrl.queryInProgress = false;
        if (customSearchCtrl.searchInput && customSearchCtrl.searchInput != '') customSearchCtrl.submitSearch()
      });

      customSearchCtrl.getLastUpdatedDaysClass = function(lastUpdatedDays) {
        return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
      };

      customSearchCtrl.addSelectedTo = function(list, selectedApps) {
        listApiService.addSelectedTo(list, selectedApps, customSearchCtrl.platform).success(function() {
          customSearchCtrl.notify('add-selected-success');
          $rootScope.selectedAppsForList = [];
        }).error(function() {
          customSearchCtrl.notify('add-selected-error');
        });
        $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
      };

      customSearchCtrl.notify = function(type) {
        listApiService.listAddNotify(type);
      };

      customSearchCtrl.appsDisplayedCount = function() {
        var lastPageMaxApps = customSearchCtrl.numPerPage * customSearchCtrl.currentPage;
        var baseAppNum = customSearchCtrl.numPerPage * (customSearchCtrl.currentPage - 1) + 1;

        if (lastPageMaxApps > customSearchCtrl.numApps) {
          return "" + baseAppNum.toLocaleString() + " - " + customSearchCtrl.numApps.toLocaleString();
        } else {
          return "" + baseAppNum.toLocaleString() + " - " + lastPageMaxApps.toLocaleString();
        }
      };

      customSearchCtrl.customSearchLinkClicked = function (type, item) {
        mixpanel.track("Custom Search Link Clicked", {
          "type": type,
          "id": item.id,
          "name": item.name,
          "platform": customSearchCtrl.platform,
          "query": customSearchCtrl.searchInput
        })
      }

    }
  ]);
