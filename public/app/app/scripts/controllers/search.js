'use strict';

angular.module('appApp')
  .controller('SearchCtrl', ["$scope", "$location", "authToken", "$rootScope", "$routeParams", "$http", "$window", "searchService",
    function ($scope, $location, authToken, $rootScope, $routeParams, $http, $window, searchService) {

      var searchCtrl = this; // same as searchCtrl = $scope

      console.log('SEARCH', $location.url().split('search')[1]);

      /* For query load when /search/:query path hit */
      searchCtrl.loadTableData = function() {

        var submitSearchStartTime = new Date().getTime();

        $scope.queryInProgress = true;

        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/filter_' + APP_PLATFORM + '_apps' + $location.url().split('search')[1]
        })
          .success(function(data) {
            console.log('YAYYYYYY', data);
            searchCtrl.apps = data.results;
            searchCtrl.numApps = data.resultsCount;
            $rootScope.dashboardSearchButtonDisabled = false;
            searchCtrl.currentPage = 1;
            searchCtrl.resultsSortCategory = 'appName';
            searchCtrl.resultsOrderBy = 'ASC';

            var submitSearchEndTime = new Date().getTime();

            var submitSearchElapsedTime = submitSearchEndTime - submitSearchStartTime;

            /* -------- Mixpanel Analytics Start -------- */
            var searchQueryPairs = {};
            var searchQueryFields = [];
            $rootScope.tags.forEach(function(tag) {
              searchQueryPairs[tag.parameter] = tag.value;
              searchQueryFields.push(tag.parameter);
            });
            searchQueryPairs['tags'] = searchQueryFields;
            searchQueryPairs['numOfApps'] = data.resultsCount;
            searchQueryPairs['elapsedTimeInMS'] = submitSearchElapsedTime;
            searchQueryPairs['platform']  = APP_PLATFORM;

            mixpanel.track(
              "Search Request Successful",
              searchQueryPairs
            );
            /* -------- Mixpanel Analytics End -------- */

          })
          .error(function(data, status) {
            $rootScope.dashboardSearchButtonDisabled = false;
            mixpanel.track(
              "Search Request Failed",
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
      if($location.url().split('search')[1]) {
        searchCtrl.loadTableData();
      }

      // When main Dashboard search button is clicked
      searchCtrl.submitSearch = function() {
        $window.location.href = "/app/app#/search?" + searchService.queryStringParameters($rootScope.tags, 1, $rootScope.numPerPage, searchCtrl.resultsSortCategory, searchCtrl.resultsOrderBy);
        console.log('SEARCH2', $location.url().split('search')[1]);
        // searchCtrl.loadTableData();
        $window.location.reload();
      };

    }
  ]);
