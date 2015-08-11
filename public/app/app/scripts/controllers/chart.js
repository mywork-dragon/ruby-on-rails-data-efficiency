'use strict';

angular.module('appApp').controller("ChartCtrl", ["$scope", "$http", "pageTitleService", "listApiService",
  function($scope, $http, pageTitleService, listApiService) {

    var chartCtrl = this; // same as chartCtrl = $scope

    chartCtrl.load = function() {

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newest_apps_chart'
      }).success(function(data) {
        chartCtrl.chartData = data;

        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Newest Apps');

      });

    };

    chartCtrl.load();

    chartCtrl.addMixedSelectedTo = function(list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
        chartCtrl.notify('add-selected-success');
        chartCtrl.selectedAppsForList = [];
      }).error(function() {
        chartCtrl.notify('add-selected-error');
      });
      chartCtrl['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "Newest Chart Viewed", {
        "pageType": "Chart"
      }
    );
    /* -------- Mixpanel Analytics End -------- */
  }
]);
