'use strict';

angular.module("appApp")
  .factory("searchService", ["$httpParamSerializer", "AppPlatform", "filterService", function($httpParamSerializer, AppPlatform, filterService) {
    return {
      queryStringParameters: function(tags, currentPage, numPerPage, category, order) {
        var requestData = {app: {}, company: {}, platform: {}};
        if (tags) {
          tags.forEach(function (tag) {
            switch (tag.parameter) {
              case 'categories':
              case 'userBases':
              case 'mobilePriority':
              case 'supportDesk':
              case 'sdkFiltersOr':
              case 'sdkFiltersAnd':
              case 'locationFiltersOr':
              case 'locationFiltersAnd':
              case 'userbaseFiltersAnd':
              case 'userbaseFiltersOr':
              case 'downloads':
                if (requestData['app'][tag.parameter]) {
                  requestData['app'][tag.parameter].push(tag.value);
                } else {
                  requestData['app'][tag.parameter] = [tag.value];
                }
                break;
              case 'updatedDaysAgo':
              case 'adSpend':
              case 'inAppPurchases':
              case 'price':
                requestData['app'][tag.parameter] = tag.value;
                break;
              case 'fortuneRank':
                requestData['company'][tag.parameter] = tag.value;
                break;
              case 'customKeywords':
                if (requestData['custom'][tag.parameter]) {
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

        requestData['platform']['appPlatform'] = AppPlatform.platform;

        return $httpParamSerializer(requestData);
      },
      searchFilters: function(param, value) {
        switch (param) {
          case 'price':
            return {
              parameter: param,
              text: "Price" + ": " + value,
              value: value
            };
            break;
          case 'inAppPurchases':
            return {
              parameter: param,
              text: "In App Purchases" + ": " + value,
              value: value
            };
            break;
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
          case 'sdkFiltersOr':
          case 'sdkFiltersAnd':
            var filterTypeShort = param == 'sdkFiltersAnd' ? 'And' : 'Or'
            var displayName = filterService.sdkDisplayText(value, filterTypeShort)
            return {
              parameter: param,
              text: displayName + ": " + value.name,
              value: value
            };
            break;
          case 'locationFiltersOr':
          case 'locationFiltersAnd':
            var filterTypeShort = param == 'locationFiltersAnd' ? 'And' : 'Or'
            var displayName = filterService.locationDisplayText(value, filterTypeShort)
            var customName = value.name
            if (value.state && value.state != "0") {
              customName = value.state + ', ' + customName
            }
            return {
              parameter: param,
              text: displayName + ": " + customName,
              value: value
            };
            break;
          case 'userbaseFiltersOr':
          case 'userbaseFiltersAnd':
            var filterTypeShort = param == 'userbaseFiltersAnd' ? 'And' : 'Or'
            var displayName = filterService.userbaseDisplayText(value, filterTypeShort)
            var customName = value.name
            return {
              parameter: param,
              text: displayName + ": " + customName,
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
      },
        // Computes class for last updated data in Last Updated column rows
        getLastUpdatedDaysClass: function(lastUpdatedDays) {
        if(lastUpdatedDays <= 60) {
          return 'last-updated-days-new';
        } else if(60 < lastUpdatedDays && lastUpdatedDays < 181) {
          return 'last-updated-days-medium';
        } else {
          return 'last-updated-days-old';
        }
      }
    }
  }]);
