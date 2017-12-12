import angular from 'angular';
import React from 'react';
import ReactDOM from 'react-dom';

import AdNetworkPanel from './AdNetworkPanel.component';

angular
  .module('appApp')
  .directive('adNetworkPanel', adNetworkPanel);

function adNetworkPanel() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      networks: '=',
    },
    link (scope, element) {
      ReactDOM.render(<AdNetworkPanel networks={scope.networks} />, element[0]);
    },
  };

  return directive;
}
