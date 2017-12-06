import angular from 'angular';

const template = require('./export-permissions.html')

angular.module('appApp')
.directive('exportPermissions', function() {
  return {
    scope: true,
    // controller: 'ListCtrl',
    // controllerAs: 'ctrl',
    template: template
  };
});
