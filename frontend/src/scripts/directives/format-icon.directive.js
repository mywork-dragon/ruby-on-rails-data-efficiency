import angular from 'angular';

(function() {
  'use strict';

  angular
    .module('appApp')
    .directive('formatIcon', formatIcon);

  function formatIcon() {
    var directive = {
      restrict: 'EA',
      template: '<i class="format-icon fa fa-fw fa-{{icon}}" uib-tooltip="{{format | capitalize}}" ng-click="onClick()"></i>',
      scope: {
        format: "=",
        onClick: "&"
      },
      link: linkFunc
    };

    return directive;

    function linkFunc(scope, el, attr, ctrl) {
      const iconMap = {
        'html': 'html5',
        'image': 'picture-o',
        'video': 'film'
      }

      scope.icon = iconMap[scope.format]
    }
  }
})();
