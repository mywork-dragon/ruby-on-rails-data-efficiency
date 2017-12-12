import angular from 'angular';

const template = require('./top-header.html');

angular.module('appApp')
  .directive('topHeader', () => ({
    scope: true,
    template,
  }));
