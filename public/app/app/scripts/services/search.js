'use strict';

angular.module("appApp")
  .factory("searchService", ["$httpParamSerializer", "AppPlatform", function($httpParamSerializer, AppPlatform) {
    return {
      queryStringParameters: function(tags, currentPage, numPerPage, category, order) {
        var requestData = {app: {}, company: {}, custom: {}, platform: {}};
        if (tags) {
          tags.forEach(function (tag) {
            switch (tag.parameter) {
              case 'mobilePriority':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'adSpend':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'userBases':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'updatedDaysAgo':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'categories':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'fortuneRank':
                requestData['company'][tag.parameter] = tag.value;
                break;
              case 'supportDesk':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'customKeywords':
                if (requestData['custom'][tag.parameter]) {
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

        requestData['platform']['appPlatform'] = AppPlatform.platform;

        return $httpParamSerializer(requestData);
      },
      searchFilters: function(param, value) {
        switch (param) {
          case 'mobilePriority':
            return {
              parameter: param,
              text: "Mobile Priority" + ": " + value,
              value: value
            };
            break;
          case 'fortuneRank':
            return {
              parameter: param,
              text: "Fortune Rank" + ": " + value,
              value: value
            };
            break;
          case 'adSpend':
            return {
              parameter: param,
              text: "Reported Ad Spend" + ": " + value,
              value: value
            };
            break;
          case 'userBases':
            return {
              parameter: param,
              text: "User Base Size" + ": " + value,
              value: value
            };
            break;
          case 'updatedDaysAgo':
            return {
              parameter: param,
              text: "User Base Size" + ": " + value,
              value: value
            };
            break;
          case 'categories':
            return {
              parameter: param,
              text: "Category" + ": " + value,
              value: value
            };
            break;
          case 'supportDesk':
            return {
              parameter: param,
              text: "Support Desk" + ": " + value,
              value: value
            };
            break;
          case 'customKeywords':
            return {
              parameter: param,
              text: "Custom" + ": " + value,
              value: value
            };
            break;
          case 'sdkNames':
            return {
              parameter: param,
              text: "SDK" + ": " + value.name,
              value: value
            };
            break;
          case 'downloads':
            return {
              parameter: param,
              text: "Downloads" + ": " + value.name,
              value: value
            };
            break;
        }
      }
    }
  }]);
