import angular from 'angular';
import React from 'react';
import ReactDOM from 'react-dom';

import CreativeFormatList from './CreativeFormatList.component';

angular
  .module('appApp')
  .directive('creativeFormatList', creativeFormatList);

function creativeFormatList() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      formats: '=',
    },
    link (scope, element) {
      ReactDOM.render(<CreativeFormatList formats={scope.formats} />, element[0]);
    },
  };

  return directive;
}
