import angular from 'angular';

const template = require('./help-video.html')

angular.module('appApp')
.directive('helpVideo', function() {
  return {
    scope: true,
    controller: 'VideoModalCtrl',
    controllerAs: '$ctrl',
    template: template
  };
});
