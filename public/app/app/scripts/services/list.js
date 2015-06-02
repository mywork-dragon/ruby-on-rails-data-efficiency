'use strict';

angular.module("appApp")
  .factory("listApiService", [function() {
    return {
      getLists: function() {
        return ["List 1", "List 2", "List 3", "List 4"];
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
        console.log(listName);
      },
      getList: function(listName) {
        console.log(listName);

        return {
          results: {},
          resultsCount: 0,
          currentList: listName
        }

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
