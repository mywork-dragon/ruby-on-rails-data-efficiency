import angular from 'angular'

const template = require('./ad-network-panel.html')

angular
  .module('appApp')
  .directive('adNetworkPanel', adNetworkPanel);

function adNetworkPanel() {
  var directive = {
    restrict: 'E',
    template: template,
    scope: {
      networks: "="
    }
  };

  return directive;
}
