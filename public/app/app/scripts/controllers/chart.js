'use strict';

angular.module('appApp').controller("ChartCtrl", ["$scope", "$http", "pageTitleService", "listApiService", "apiService",
  function($scope, $http, pageTitleService, listApiService, apiService) {

    var chartCtrl = this; // same as chartCtrl = $scope

    chartCtrl.load = function() {

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/chart/newest'
      }).success(function(data) {
        chartCtrl.chartData = data.results;

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

    chartCtrl.exportListToCsv = function() {
      apiService.exportNewestChartToCsv()
        .success(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'mightysignal_newest_apps.csv';
          hiddenElement.click();
        });
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
