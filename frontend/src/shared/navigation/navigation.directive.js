import angular from 'angular';

import 'shared/list-create/list-create.directive';

const template = require('./navigation.html')

angular.module('appApp')
.directive('navigation', function() {
  return {
    scope: true,
    controller: 'MainCtrl',
    controllerAs: 'ctrl',
    template: template
  };
});
