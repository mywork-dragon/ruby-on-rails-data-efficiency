import angular from 'angular';
import Bugsnag from 'bugsnag-js';
import jwt from 'jsonwebtoken';

angular
  .module('appApp')
  .factory('$exceptionHandler', $exceptionHandler);

// $exceptionHandler.$inject = ['$log', 'logErrorsToBackend'];

function $exceptionHandler() {
  return function bugsnagExceptionHandler(exception) {
    Bugsnag.notifyException(exception, {
      user_id: jwt.decode(localStorage.getItem('ms_jwt_auth_token')).user_id,
    });
  };
}
