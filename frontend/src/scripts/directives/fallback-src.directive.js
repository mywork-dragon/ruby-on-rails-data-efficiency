import angular from 'angular';

(function() {
    'use strict';

    angular
        .module('appApp')
        .directive('fallbackSrc', fallbackSrc);

    /* @ngInject */
    function fallbackSrc() {
      var fallbackSrc = {
      link: function postLink(scope, iElement, iAttrs) {
        iElement.bind('error', function() {
          angular.element(this).attr("src", iAttrs.fallbackSrc);
        });
      }}

      return fallbackSrc;
    }
})();
