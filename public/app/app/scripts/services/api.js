'use strict';

angular.module("appApp")
  .factory("apiService", ['$http', function($http) {
    return {
      /* Translates tag object values into a request object that matches format of back end api endpoints */
      searchRequestPost: function(tags, currentPage, numPerPage, category, order) {
        var requestData = {app: {}, company: {}};
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
                }                break;
              case 'customKeywords':
                if(requestData[tag.parameter]) {
                  requestData[tag.parameter].push(tag.value);
                } else {
                  requestData[tag.parameter] = [tag.value];
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
          data: requestData
        });
      },
      getCategories: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + APP_PLATFORM + '_categories'
        });
      },
      getCompanyContacts: function(websites) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/company/contacts',
          data: {
            companyWebsites: websites
          }
        });
      }
    };
  }]);

