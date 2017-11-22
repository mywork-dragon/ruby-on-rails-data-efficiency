import angular from 'angular';

(function() {
  'use strict';

  angular
    .module('appApp')
    .service('csvUtils', csvUtils);

  csvUtils.$inject = [];

  function csvUtils() {
    return {
      downloadCsv
    }

    function downloadCsv(content, name) {
      var hiddenElement = document.createElement('a');
      hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
      hiddenElement.target = '_blank';
      hiddenElement.download = name + '.csv';
      hiddenElement.click();
    }
  }
})();
