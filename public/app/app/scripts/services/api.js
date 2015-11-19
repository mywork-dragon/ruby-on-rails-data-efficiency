'use strict';

angular.module("appApp")
  .factory("apiService", ['$http', function($http) {
    return {
      /* Translates tag object values into a request object that matches format of back end api endpoints */
      searchRequestPost: function(tags, currentPage, numPerPage, category, order) {
        var requestData = {app: {}, company: {}, custom: {}};
        if(tags) {
          tags.forEach(function (tag) {
            switch (tag.parameter) {
              case 'mobilePriority':
                if(requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'adSpend':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'userBases':
                if(requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'updatedDaysAgo':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'categories':
                if(requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'fortuneRank':
                requestData['company'][tag.parameter] = tag.value;
                break;
              case 'supportDesk':
                if(requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'customKeywords':
                if(requestData['custom'][tag.parameter]) {
                  requestData['custom'][tag.parameter].push(tag.value);
                } else {
                  requestData['custom'][tag.parameter] = [tag.value];
                }
                break;
              case 'sdkNames':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'downloads':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
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
          url: API_URI_BASE + 'api/filter_' + APP_PLATFORM + '_apps',
          params: requestData
        });
      },
      getCategories: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        });
      },
      getCompanyContacts: function(websites, filter) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/company/contacts',
          data: {
            companyWebsites: websites,
            filter: filter
          }
        });
      },
      exportContactsToCsv: function(contacts, companyName) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported Contacts CSV", {
            "contacts": contacts
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/contacts/export_to_csv',
          data: {
            contacts: contacts,
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
      exportAllToCsv: function() {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported Search Results CSV"
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/search/export_results_to_csv'
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
