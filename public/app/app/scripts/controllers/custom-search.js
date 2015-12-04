'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', ['$rootScope', 'customSearchService', '$httpParamSerializer', '$location', 'listApiService', "authService", "searchService",
    function($rootScope, customSearchService, $httpParamSerializer, $location, listApiService, authService, searchService) {

      var customSearchCtrl = this;

      customSearchCtrl.platform = APP_PLATFORM; // default

      // User info set
      var userInfo = {};
      authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

      /* For query load when /search/:query path hit */
      customSearchCtrl.loadTableData = function() {

        customSearchCtrl.queryInProgress = true;

        var urlParams = $location.url().split('/search/custom')[1]; // Get url params
        var routeParams = $location.search();

        customSearchService.customSearch(routeParams.platform, routeParams.query, routeParams.page, routeParams.numPerPage)
          .success(function(data) {
            customSearchCtrl.apps = data.appData;
            customSearchCtrl.appNum = data.appData.length;
            customSearchCtrl.numApps = data.totalAppsCount;
            customSearchCtrl.numPerPage = data.numPerPage;
            customSearchCtrl.changeAppPlatform(routeParams.platform);
            customSearchCtrl.searchInput = routeParams.query;
            customSearchCtrl.currentPage = data.page;
            customSearchCtrl.queryInProgress = false;
            $rootScope.apps = customSearchCtrl.apps;
            $rootScope.numApps = customSearchCtrl.numApps;
          })
          .error(function(data) {
            customSearchCtrl.appNum = 0;
            customSearchCtrl.numApps = 0;
            customSearchCtrl.queryInProgress = false;
          });
      };

      customSearchCtrl.loadTableData();

      customSearchCtrl.changeAppPlatform = function(platform) {
        customSearchCtrl.platform = platform;
      };

      customSearchCtrl.onPageChange = function(nextPage) {
        customSearchCtrl.submitSearch(nextPage);
      };

      customSearchCtrl.submitSearch = function(newPageNum) {
        var payload = {
          query: customSearchCtrl.searchInput,
          platform: customSearchCtrl.platform,
          page: newPageNum || 1,
          numPerPage: 30
        };
        var targetUrl = '';
        if(customSearchCtrl.platform == 'iosSdks') {
          targetUrl = '/search/iosSdks?';
        } else if(customSearchCtrl.platform == 'androidSdks') {
          targetUrl = '/search/androidSdks?';
        } else {
          targetUrl = '/search/custom?';
        }
        $location.url(targetUrl + $httpParamSerializer(payload));
        customSearchCtrl.loadTableData();
        if(customSearchCtrl.platform == 'androidSdks' || customSearchCtrl.platform == 'iosSdks') {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Custom Search", {
              "query": customSearchCtrl.searchInput,
              "platform": customSearchCtrl.platform.split('Sdks')[0] // grabs 'android' or 'ios'
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          if(userInfo.email && userInfo.email.indexOf('mightysignal') < 0) {
            var slacktivityData = {
              "title": "SDK Custom Search",
              "fallback": "SDK Custom Search",
              "color": "#FFD94D", // yellow
              "userEmail": userInfo.email,
              "platform": customSearchCtrl.platform,
              "query": customSearchCtrl.searchInput
            };
            if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
            window.Slacktivity.send(slacktivityData);
          }
          /* -------- Slacktivity Alerts End -------- */
        } else {
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
          return "" + baseAppNum + " - " + customSearchCtrl.numApps;
        } else {
          return "" + baseAppNum + " - " + lastPageMaxApps;
        }
      };

    }
  ]);
