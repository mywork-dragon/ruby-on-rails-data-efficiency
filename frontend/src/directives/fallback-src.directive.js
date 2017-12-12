import angular from 'angular';

(function() {
  angular
    .module('appApp')
    .directive('fallbackSrc', fallbackSrc);

  /* @ngInject */
  function fallbackSrc() {
    const directive = {
      link: function postLink(scope, iElement, iAttrs) {
        iElement.bind('error', function() {
          angular.element(this).attr('src', iAttrs.fallbackSrc);
        });
      },
    };

    return directive;
  }
}());
