import angular from 'angular';
import React from 'react';
import { render, unmountComponentAtNode } from 'react-dom';
import { store } from 'store';
import { Provider } from 'react-redux';

import ExploreContainer from './Explore.container';

angular
  .module('appApp')
  .directive('explore', explore);

explore.$inject = ['$stateParams'];

function explore($stateParams) {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    controller: ExploreController,
    bindToController: true,
    link (scope, element) {
      scope.$watch('itemId', renderReactElement);

      scope.$on('$destroy', unmountReactElement);

      function renderReactElement() {
        render(
          <Provider store={store}>
            <ExploreContainer
              queryId={$stateParams.queryId}
            />
          </Provider>
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

ExploreController.$inject = ['$rootScope', '$state', 'pageTitleService'];

function ExploreController($rootScope, $state, pageTitleService) {
  activate();

  function activate () {
    if (!$rootScope.isAdminAccount) {
      $state.go('search');
    }
    pageTitleService.setTitle('MightySignal - Explore');
  }
}
