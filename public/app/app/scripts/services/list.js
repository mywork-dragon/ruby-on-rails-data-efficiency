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
      modifyCheckbox: function(selectedAppId, selectedAppType, list) {
        // Check if app id is already in list
        var index = list.map(function(x) {return x.id; }).indexOf(selectedAppId);
        if (index > -1) {
          list.splice(index, 1);
        } else {
          list.push({id: selectedAppId, type: selectedAppType});
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
      getList: function(listId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/list/get_list',
          params: {listId: listId}
        });
      },
      addSelectedTo: function(listId, selectedApps, appPlatform) {
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/add',
          data: {listId: listId, apps: selectedApps, appPlatform: appPlatform}
        });
      },
      deleteSelected: function(listId, selectedApps) {
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/delete_items',
          data: {listId: listId, apps: selectedApps}
        });
      },
      deleteList: function(listId) {
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/delete',
          data: {listId: listId}
        });
      },
      exportToCsv: function(listName) {
        console.log(listName);
      }
    }
  }]);
