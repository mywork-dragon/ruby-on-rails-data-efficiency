import angular from 'angular';
import React from 'react';
import { render, unmountComponentAtNode } from 'react-dom';
import { store } from 'store';
import { Provider } from 'react-redux';
import ErrorBoundary from 'components/bugsnag-wrapper/BugsnagWrapper.component';

import PublisherAdIntelTabContainer from 'containers/PublisherPage/containers/PublisherAdIntel.container';
import AppAdIntelTabContainer from 'containers/AppPage/containers/AppAdIntel.container';

angular
  .module('appApp')
  .directive('adIntelTab', adIntelTab);

function adIntelTab() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      type: '=',
      platform: '=',
      itemId: '=',
    },
    link (scope, element) {
      scope.$watch('itemId', renderReactElement);

      scope.$on('$destroy', unmountReactElement);

      function renderReactElement() {
        render(
          <ErrorBoundary>
            <Provider store={store}>
              { scope.type === 'app' ?
                <AppAdIntelTabContainer itemId={scope.itemId} platform={scope.platform} />
                : <PublisherAdIntelTabContainer itemId={scope.itemId} platform={scope.platform} />
              }
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
