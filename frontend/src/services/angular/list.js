import angular from 'angular';
import mixpanel from 'mixpanel-browser';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('listApiService', ['$http', 'loggitService', function($http, loggitService) {
    var outstanding_get_lists = false;

    return {
      getLists() {
        if (outstanding_get_lists) {
          return outstanding_get_lists;
        }
        outstanding_get_lists = $http({
          method: 'GET',
          url: `${API_URI_BASE}api/list/get_lists`,
        });
        // Cache response for 5 seconds.
        outstanding_get_lists.then((response) => {
          setTimeout(function(){
            outstanding_get_lists = false;
          }, 5000);
        });
        return outstanding_get_lists;
      },
      modifyCheckbox(selectedAppId, selectedAppType, list) {
        // Check if app id is already in list
        const index = list.map(x => x.id).indexOf(selectedAppId);
        if (index > -1) {
          list.splice(index, 1);
        } else {
          list.push({ id: selectedAppId, type: selectedAppType });
        }
      },
      createNewList(listName) {
        outstanding_get_lists = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('New List Created', {
          listName,
        });
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/list/create_new`,
          data: { listName },
        });
      },
      getList(listId, page) {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/list/get_list`,
          params: { listId, page },
        });
      },
      addSelectedTo(listId, selectedApps) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('Added to List', {
          listId,
          selectedApps,
        });
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'PUT',
          url: `${API_URI_BASE}api/list/add`,
          data: { listId, apps: selectedApps },
        });
      },
      deleteSelected(listId, selectedApps) {
        return $http({
          method: 'PUT',
          url: `${API_URI_BASE}api/list/delete_items`,
          data: { listId, apps: selectedApps },
        });
      },
      deleteList(listId) {
        outstanding_get_lists = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('Deleted List', {
          listId,
        });
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'PUT',
          url: `${API_URI_BASE}api/list/delete`,
          data: { listId },
        });
      },
      exportToCsv(listId) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track('List Exported to CSV', {
          listId,
        });
        /* -------- Mixpanel Analytics End -------- */
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/list/export_to_csv`,
          params: { listId },
        });
      },
      listAddNotify(type) {
        switch (type) {
          case 'add-selected-success':
            return loggitService.logSuccess('Items were added successfully.');
          case 'add-selected-error':
            return loggitService.logError('Error! Something went wrong while adding to list.');
        }
      },
    };
  }]);
