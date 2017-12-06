import angular from 'angular';

const template = require('./list-delete-selected.html')

angular.module('appApp')
.directive('listDeleteSelected', function() {
  return {
    scope: true,
    controller: 'ListCtrl',
    controllerAs: 'ctrl',
    template: template
  };
});
