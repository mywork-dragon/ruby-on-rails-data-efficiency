import angular from 'angular';

import 'components/list-create/list-create.directive';

const template = require('./navigation.html');

angular.module('appApp')
  .directive('navigation', () => ({
    scope: true,
    controller: 'MainCtrl',
    controllerAs: 'ctrl',
    template,
  }));
