'use strict';

angular.module("appApp").factory("apiService", ['$http', function($http) {

  return {
    searchRequestPost: function(tags, currentPage, numPerPage, category, order) {
      var requestData = {app: {}, company: {}};
      if(tags) {
        tags.forEach(function (tag) {
          switch (tag.parameter) {
            case 'mobilePriority':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'adSpend':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'userBases':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'updatedDaysAgo':
              requestData['app'][tag.parameter] = tag.value;
              break;
            case 'categories':
              requestData['app'][tag.parameter] = [tag.value];
              break;
            case 'fortuneRank':
              requestData['company'][tag.parameter] = tag.value;
              break;
            case 'customKeywords':
              requestData[tag.parameter] = [tag.value];
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
        //url: 'http://mightysignal.com/api/filter_ios_apps',
        url: 'http://localhost:3000/api/filter_ios_apps',
        data: requestData
      });

    }
  };

}]);
