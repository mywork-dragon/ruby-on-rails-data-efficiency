import angular from 'angular';
import _ from 'lodash';

import 'AngularService/api-token.service';

angular.module('appApp').controller('apiTokenInstanceCtrl', ['$uibModalInstance', 'id', 'apiTokenService', function ($uibModalInstance, id, apiTokenService) {
  const $ctrl = this;
  $ctrl.id = id;
  $ctrl.tokens = {};
  $ctrl.rateLimit = '';
  $ctrl.rateWindow = '';
  $ctrl.tokenLimit = '';
  $ctrl.tokenWindow = '';

  apiTokenService.getApiTokens(id).success((data) => {
    data.forEach((token) => {
      $ctrl.tokens[token.id] = token;
    });
    $ctrl.empty = _.isEmpty($ctrl.tokens);
  });

  $ctrl.toggleEditForm = function (tokenId) {
    if (tokenId) {
      const token = $ctrl.tokens[tokenId];
      $ctrl.tokenLimit = token.rate_limit;
      $ctrl.tokenWindow = token.rate_window;
    } else {
      $ctrl.tokenLimit = '';
      $ctrl.tokenWindow = '';
    }
    $ctrl.currentlyEditing = tokenId;
  };

  $ctrl.updateToken = function (tokenId, newData) {
    apiTokenService.updateToken(tokenId, newData)
      .success((data) => {
        $ctrl.tokens[data.id] = data;
        $ctrl.currentlyEditing = null;
        apiTokenService.toast('token-update-success');
      })
      .error(() => {
        apiTokenService.toast('token-update-failure');
      });
  };

  $ctrl.generateToken = function(rateLimit, rateWindow) {
    apiTokenService.generateToken($ctrl.id, rateLimit, rateWindow)
      .success((data) => {
        $ctrl.tokens[data.id] = data;
        $ctrl.empty = false;
        $ctrl.rateLimit = '';
        $ctrl.rateWindow = '';
        apiTokenService.toast('token-create-success');
      })
      .error(() => {
        apiTokenService.toast('token-create-failure');
      });
  };

  $ctrl.deleteToken = function (tokenId) {
    apiTokenService.deleteToken(tokenId)
      .success((data) => {
        delete $ctrl.tokens[data.id];
        $ctrl.empty = _.isEmpty($ctrl.tokens);
        apiTokenService.toast('token-delete-success');
      })
      .error(() => {
        apiTokenService.toast('token-delete-failure');
      });
  };
}]);
