'use strict';

angular.module("appApp")
  .factory("apiService", ['$http', function($http) {
    return {
      /* Translates tag object values into a request object that matches format of back end api endpoints */
      searchRequestPost: function(tags, currentPage, numPerPage, category, order, platform) {
        var requestData = {app: {}, company: {}};
        if(tags) {
          tags.forEach(function (tag) {
            switch (tag.parameter) {
              case 'mobilePriority':
              case 'userBases':
              case 'categories':
              case 'supportDesk':
              case 'sdkFiltersOr':
              case 'sdkFiltersAnd':
              case 'locationFiltersAnd':
              case 'locationFiltersOr':
              case 'userbaseFiltersAnd':
              case 'userbaseFiltersOr':
              case 'downloads':
                if(requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'oldAdSpend':
              case 'adSpend':
              case 'updatedDaysAgo':
              case 'inAppPurchases':
              case 'price':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'fortuneRank':
                requestData['company'][tag.parameter] = tag.value;
                break;
              case 'customKeywords':
                if(requestData['custom'][tag.parameter]) {
                  requestData['custom'][tag.parameter].push(tag.value);
                } else {
                  requestData['custom'][tag.parameter] = [tag.value];
                }
                break;
            }
          });
        }
        if (currentPage && numPerPage) {
          requestData.pageNum = currentPage;
          requestData.pageSize = numPerPage;
        }
        if (category && order) {
          requestData.sortBy = category;
          requestData.orderBy = order;
        }
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/filter_' + platform + '_apps',
          params: requestData
        });
      },
      getCategories: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        });
      },
      getCompanyContacts: function(platform, publisherId, filter, page, contactsPerPage) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/company/contacts',
          data: {
            platform: platform,
            publisherId: publisherId,
            filter: filter,
            page: page,
            perPage: contactsPerPage
          }
        });
      },
      getContactEmail: function(clearbitId) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/company/contact',
          data: {
            contactId: clearbitId,
          }
        });
      },
      exportContactsToCsv: function(platform, publisherId, filter, companyName) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported Contacts CSV", {
            'filter': filter,
            'companyName': companyName,
            'publisherId': publisherId,
            'platform': platform
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/contacts/export_to_csv',
          data: {
            platform: platform,
            publisherId: publisherId,
            filter: filter,
            companyName: companyName
          }
        });
      },
      exportNewestChartToCsv: function() {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported Newest Apps CSV"
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/chart/export_to_csv'
        });
      },
      exportAllToCsv: function(params) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported Search Results CSV"
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/search/export_to_csv.csv' + params
        });
      },
      checkForSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/android_sdks_exist',
          params: {appId: appId}
        })
      },
      getSdks: function(appId, endPoint) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + endPoint,
          params: {appId: appId}
        })
      },
      getScannedSdkNum: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/sdk/scanned_count'
        })
      }
    };
  }]);
