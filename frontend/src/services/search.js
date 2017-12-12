import angular from 'angular';

angular.module('appApp')
  .factory('searchService', ['$httpParamSerializer', 'AppPlatform', 'filterService', '$rootScope', function($httpParamSerializer, AppPlatform, filterService, $rootScope) {
    return {
      queryStringParameters(tags, currentPage, numPerPage, category, order) {
        const requestData = { app: {}, company: {}, platform: {} };
        if (tags) {
          tags.forEach((tag) => {
            switch (tag.parameter) {
              case 'categories':
              case 'userBases':
              case 'mobilePriority':
              case 'supportDesk':
              case 'sdkFiltersOr':
              case 'sdkFiltersAnd':
              case 'sdkCategoryFiltersOr':
              case 'sdkCategoryFiltersAnd':
              case 'locationFiltersOr':
              case 'locationFiltersAnd':
              case 'userbaseFiltersAnd':
              case 'userbaseFiltersOr':
              case 'downloads':
                if (requestData.app[tag.parameter]) {
                  requestData.app[tag.parameter].push(tag.value);
                } else {
                  requestData.app[tag.parameter] = [tag.value];
                }
                break;
              case 'updatedDaysAgo':
              case 'adSpend':
              case 'inAppPurchases':
              case 'price':
                requestData.app[tag.parameter] = tag.value;
                break;
              case 'fortuneRank':
                requestData.company[tag.parameter] = tag.value;
                break;
              case 'customKeywords':
                if (requestData.custom[tag.parameter]) {
                  requestData.custom[tag.parameter].push(tag.value);
                } else {
                  requestData.custom[tag.parameter] = [tag.value];
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

        requestData.platform.appPlatform = AppPlatform.platform;

        return $httpParamSerializer(requestData);
      },
      searchFilters(param, value) {
        let filterTypeShort;
        let displayName;
        let customName;
        switch (param) {
          case 'price':
            return {
              parameter: param,
              text: `Price: ${value}`,
              value,
            };
          case 'inAppPurchases':
            return {
              parameter: param,
              text: `In App Purchases: ${value}`,
              value,
            };
          case 'mobilePriority':
            return {
              parameter: param,
              text: `Mobile Priority: ${value}`,
              value,
            };
          case 'fortuneRank':
            return {
              parameter: param,
              text: `Fortune Rank: ${value}`,
              value,
            };
          case 'adSpend':
            return {
              parameter: param,
              text: 'Facebook Ads: Yes',
              value,
            };
          case 'userBases':
            return {
              parameter: param,
              text: `User Base Size: ${value}`,
              value,
            };
          case 'updatedDaysAgo':
            return {
              parameter: param,
              text: `User Base Size: ${value}`,
              value,
            };
          case 'categories':
            return {
              parameter: param,
              text: `Category: ${value}`,
              value,
            };
          case 'supportDesk':
            return {
              parameter: param,
              text: `Support Desk: ${value}`,
              value,
            };
          case 'customKeywords':
            return {
              parameter: param,
              text: `Custom: ${value}`,
              value,
            };
          case 'sdkFiltersOr':
          case 'sdkFiltersAnd':
            filterTypeShort = param === 'sdkFiltersAnd' ? 'And' : 'Or';
            displayName = filterService.sdkDisplayText(value, filterTypeShort, 'sdk');
            return {
              parameter: param,
              text: `${displayName}: ${value.name}`,
              value,
            };
          case 'sdkCategoryFiltersOr':
          case 'sdkCategoryFiltersAnd':
            filterTypeShort = param === 'sdkCategoryFiltersAnd' ? 'And' : 'Or';
            displayName = filterService.sdkDisplayText(value, filterTypeShort, 'sdkCategory');
            return {
              parameter: param,
              text: `${displayName}: ${value.name}`,
              value,
            };
          case 'locationFiltersOr':
          case 'locationFiltersAnd':
            filterTypeShort = param === 'locationFiltersAnd' ? 'And' : 'Or';
            displayName = filterService.locationDisplayText(value, filterTypeShort);
            customName = value.name;
            if (value.state && value.state !== '0') {
              customName = `${value.state}, ${customName}`;
            }
            return {
              parameter: param,
              text: `${displayName}: ${customName}`,
              value,
            };
          case 'userbaseFiltersOr':
          case 'userbaseFiltersAnd':
            filterTypeShort = param === 'userbaseFiltersAnd' ? 'And' : 'Or';
            displayName = filterService.userbaseDisplayText(value, filterTypeShort);
            customName = value.name;
            return {
              parameter: param,
              text: `${displayName}: ${customName}`,
              value,
            };
          case 'downloads':
            const name = $rootScope.downloadsFilterOptions[value].label;
            return {
              parameter: param,
              text: `Downloads: ${name}`,
              value,
            };
        }
      },
      // Computes class for last updated data in Last Updated column rows
      getLastUpdatedDaysClass(lastUpdatedDays) {
        if (lastUpdatedDays <= 60) {
          return 'last-updated-days-new';
        } else if (lastUpdatedDays > 60 && lastUpdatedDays < 181) {
          return 'last-updated-days-medium';
        }
        return 'last-updated-days-old';
      },
    };
  }]);
