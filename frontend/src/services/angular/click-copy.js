import angular from 'angular';

angular
  .module('appApp')
  .service('ngCopy', ['$window', function ($window) {
    const body = angular.element($window.document.body);
    const textarea = angular.element('<textarea/>');
    textarea.css({
      position: 'fixed',
      opacity: '0',
    });

    return function (toCopy) {
      textarea.val(toCopy);
      body.append(textarea);
      textarea[0].select();

      try {
        const successful = document.execCommand('copy');
        if (!successful) throw successful;
      } catch (err) {
        window.prompt('Copy to clipboard: Ctrl+C, Enter', toCopy);
      }

      textarea.remove();
    };
  }])
  .directive('ngClickCopy', ['ngCopy', function (ngCopy) {
    return {
      restrict: 'A',
      link(scope, element, attrs) {
        element.bind('click', () => {
          ngCopy(attrs.ngClickCopy);
        });
      },
    };
  }]);
