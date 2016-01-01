'use strict';

angular.module("appApp")
  .service("appDataService", [
    function() {
      var appDataService = this;
      appDataService.displayStatus = {appId: -1, status: ""};
    }
  ]);
