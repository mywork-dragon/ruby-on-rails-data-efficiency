import angular from 'angular';

const template = require('./list-delete.html');

angular.module('appApp')
  .directive('listDelete', () => ({
    scope: true,
    controller: 'ListCtrl',
    controllerAs: 'ctrl',
    template,
  }));
