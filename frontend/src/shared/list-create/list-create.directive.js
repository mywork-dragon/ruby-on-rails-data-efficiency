import angular from 'angular';

const template = require('./list-create.html')

angular.module('appApp')
.directive('listCreate', function() {
  return {
    scope: true,
    controller: 'ListCtrl',
    controllerAs: 'ctrl',
    template: template
  };
});
