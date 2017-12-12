import angular from 'angular';

const template = require('./export-permissions.html');

angular.module('appApp')
  .directive('exportPermissions', () => ({
    scope: true,
    template,
  }));
