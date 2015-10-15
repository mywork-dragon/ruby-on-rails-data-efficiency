'use strict';

angular.module("appApp")
  .factory("listApiService", ["$http", "loggitService", function($http, loggitService) {
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
      },
      createNewList: function(listName) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "New List Created", {
            "listName": listName
          }
        );
        /* -------- Mixpanel Analytics End -------- */
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
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Added to List", {
            "listId": listId,
            "selectedApps": selectedApps,
            "appPlatform": appPlatform
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/add',
          data: {listId: listId, apps: selectedApps, appPlatform: appPlatform}
        });
      },
      addMixedSelectedTo: function(listId, selectedApps) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Added to List", {
            "listId": listId,
            "selectedApps": selectedApps
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/add_mixed',
          data: {listId: listId, apps: selectedApps}
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
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Deleted List", {
            "listId": listId
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'PUT',
          url: API_URI_BASE + 'api/list/delete',
          data: {listId: listId}
        });
      },
      exportToCsv: function(listId) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Exported CSV", {
            "listId": listId
          }
        );
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/list/export_to_csv',
          params: {listId: listId}
        });
      },
      listAddNotify: function(type) {
        switch (type) {
          case "add-selected-success":
            return loggitService.logSuccess("Items were added successfully.");
          case "add-selected-error":
            return loggitService.logError("Error! Something went wrong while adding to list.");
        }
      }
    }
  }]);
