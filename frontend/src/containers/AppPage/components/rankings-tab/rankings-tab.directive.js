import angular from 'angular';
import React from 'react';
import { render, unmountComponentAtNode } from 'react-dom';
import { store } from 'store';
import { Provider } from 'react-redux';
import ErrorBoundary from 'components/bugsnag-wrapper/BugsnagWrapper.component';

import RankingsTab from './RankingsTab.container';

angular
  .module('appApp')
  .directive('rankingsTab', rankingsTab);

function rankingsTab() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      rankings: '=',
      platform: '=',
      newcomers: '=',
      itemId: '=',
    },
    link (scope, element) {
      scope.$watchGroup(['rankings', 'itemId'], renderReactElement);

      scope.$on('$destroy', unmountReactElement);

      function renderReactElement() {
        render(
          <ErrorBoundary>
            <Provider store={store}>
              <RankingsTab {...scope} />
            </Provider>
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
