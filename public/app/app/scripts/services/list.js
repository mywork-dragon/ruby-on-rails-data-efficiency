'use strict';

angular.module("appApp")
  .factory("listApiService", ["$http", function($http) {
    return {
      getLists: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/list/get_lists'
        });
      },
      modifyCheckbox: function(selectedAppId, list) {
        // Check if app id is already in list
        var index = list.indexOf(selectedAppId);
        if (index > -1) {
          list.splice(index, 1);
        } else {
          list.push(selectedAppId);
        }
        console.log(list);
      },
      createNewList: function(listName) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/list/create_new',
          data: {listName: listName}
        });
      },
      getList: function(listName) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/list/get_list',
          data: {listName: listName}
        });
      },
      addSelectedTo: function(list, selectedApps) {
        console.log(list, selectedApps);
      },
      deleteSelected: function(listName, selectedApps) {
        console.log(listName, selectedApps);
      },
      exportToCsv: function(listName) {
        console.log(listName);
      }
    }
  }]);
