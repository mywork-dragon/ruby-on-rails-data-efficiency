'use strict';

angular.module('appApp')
  .controller('CustomSearchCtrl', [function() {

    var customSearchCtrl = this;

    customSearchCtrl.platform = 'ios'; // default

    customSearchCtrl.changeAppPlatform = function(platform) {
      customSearchCtrl.platform = platform;
    };

    customSearchCtrl.submitSearch = function() {
      alert(customSearchCtrl.searchInput);
    }

  }]);
