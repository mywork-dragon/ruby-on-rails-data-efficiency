import angular from 'angular';

const template = require('./top-header.html')

angular.module('appApp')
.directive('topHeader', function() {
  return {
    scope: true,
    // controller: 'CustomSearchCtrl',
    // controllerAs: 'ctrl',
    template: template
  };
});
