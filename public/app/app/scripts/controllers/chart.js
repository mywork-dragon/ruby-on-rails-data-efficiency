'use strict';

angular.module('appApp').controller("ChartCtrl", ["$scope", "$http", "pageTitleService",
  function($scope, $http, pageTitleService) {

    var chartCtrl = this; // same as chartCtrl = $scope

    $scope.load = function() {

      /*
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
        params: {id: $routeParams.id}
      }).success(function(data) {
        chartCtrl.appData = data;

        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Newest Apps');

      });
    */

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
