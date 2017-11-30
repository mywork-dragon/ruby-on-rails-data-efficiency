import angular from 'angular'

const template = require('./ad-summary-panel.html')

angular
  .module('appApp')
  .directive('adSummaryPanel', adSummaryPanel);

function adSummaryPanel() {
  var directive = {
    restrict: 'E',
    template: template,
    scope: {
      firstSeenDate: "=",
      lastSeenDate: "=",
      adSdks: "=",
      platform: "=",
      formats: "=",
      numCreatives: "=",
      itemId: "=",
      itemType:"=",
      totalApps: "="
    }
  };

  return directive;
}
