import angular from 'angular';
import Bugsnag from 'bugsnag-js';
import jwt from 'jsonwebtoken';

angular
  .module('appApp')
  .factory('$exceptionHandler', $exceptionHandler);

function $exceptionHandler() {
  return function bugsnagExceptionHandler(exception) {
    Bugsnag.notifyException(exception, {
      user_id: jwt.decode(localStorage.getItem('ms_jwt_auth_token')).user_id,
    });
  };
}

angular
  .module('appApp')
  .service('bugsnagHelper', bugsnagHelper);

function bugsnagHelper() {
  return function (name, message, metaData) {
    Bugsnag.notify(name, message, {
      user_id: jwt.decode(localStorage.getItem('ms_jwt_auth_token')).user_id,
      ...metaData,
    });
  };
}
