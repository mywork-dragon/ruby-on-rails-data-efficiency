import angular from 'angular';
import React from 'react';
import { render, unmountComponentAtNode } from 'react-dom';
import ErrorBoundary from 'components/bugsnag-wrapper/BugsnagWrapper.component';

import FacebookCarousel from './facebookCarousel.component';

angular
  .module('appApp')
  .directive('facebookCarousel', facebookCarousel);

function facebookCarousel() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      ads: '=',
    },
    link (scope, element) {
      scope.$watch('ads', renderReactElement);

      scope.$on('$destroy', unmountReactElement);

      function renderReactElement() {
        render(
          <ErrorBoundary>
            <FacebookCarousel {...scope} />
          </ErrorBoundary>
          , element[0],
        );
      }

      function unmountReactElement() {
        unmountComponentAtNode(element[0]);
      }
    },
  };

  return directive;
}
