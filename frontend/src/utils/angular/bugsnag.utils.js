import angular from 'angular';
import Bugsnag from 'bugsnag-js';
import { getUserIdFromToken } from 'utils/auth.utils';

angular
  .module('appApp')
  .factory('$exceptionHandler', $exceptionHandler);

function $exceptionHandler() {
  return function bugsnagExceptionHandler(exception) {
    Bugsnag.notifyException(exception, {
      user_id: getUserIdFromToken(),
    });
  };
}

angular
  .module('appApp')
  .service('bugsnagHelper', bugsnagHelper);

function bugsnagHelper() {
  return function (name, message, metaData) {
    Bugsnag.notify(name, message, {
      user_id: getUserIdFromToken(),
      ...metaData,
    });
  };
}
