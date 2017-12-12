import angular from 'angular';
import React from 'react';
import ReactDOM from 'react-dom';

import SdkLogo from './sdkLogo.component';

angular
  .module('appApp')
  .directive('sdkLogo', sdkLogo);

function sdkLogo() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      sdk: '=',
    },
    link (scope, element) {
      ReactDOM.render(<SdkLogo sdk={scope.sdk} />, element[0]);
    },
  };

  return directive;
}
