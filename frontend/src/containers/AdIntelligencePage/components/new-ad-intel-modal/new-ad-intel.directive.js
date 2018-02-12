import angular from 'angular';

const template = require('./new-ad-intel-modal.html');

angular.module('appApp')
  .directive('adIntelModal', () => ({
    scope: {
      adNetworks: '=',
      modalNetwork: '=',
    },
    template,
  }));
