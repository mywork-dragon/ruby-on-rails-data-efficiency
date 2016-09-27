'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$scope', '$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService', "slacktivity", "searchService", "$window",
    function($scope, $rootScope, customSearchService, $httpParamSerializer, $location, listApiService, slacktivity, searchService, $window) {
      var customSearchCtrl = this;
      customSearchCtrl.platform = APP_PLATFORM; // default

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {

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
          })
          .error(function(data) {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
            customSearchCtrl.queryInProgress = false;
          });
      };

      customSearchCtrl.loadTableData();


      // When orderby/sort arrows on dashboard table are clicked
      customSearchCtrl.sortApps = function(category, order) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Table Sorting Changed", {
            "category": category,
            "order": order,
            "appPlatform": APP_PLATFORM
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
      };

      customSearchCtrl.submitSearch = function(newPageNum, keepSort) {
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

          var slacktivityData = {
            "title": "SDK Custom Search",
            "fallback": "SDK Custom Search",
            "color": "#FFD94D", // yellow
            "platform": customSearchCtrl.platform,
            "query": customSearchCtrl.searchInput
          };
          slacktivity.notifySlack(slacktivityData);

        } else {

          // Set URL & process request using Custom Search Ctrl
          $location.url(targetUrl + $httpParamSerializer(payload));
          customSearchCtrl.loadTableData();

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Custom Search", {
              "query": customSearchCtrl.searchInput,
              "platform": customSearchCtrl.platform
            }
          );
          /* -------- Mixpanel Analytics End -------- */
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

    }
  ]);
