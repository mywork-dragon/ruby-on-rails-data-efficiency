import angular from 'angular';

const template = require('./new-ad-intel-modal.html');

angular.module('appApp')
  .directive('adIntelModal', () => ({
    scope: true,
    controller: 'AdIntelligenceController',
    controllerAs: 'adIntel',
    template,
  }));
