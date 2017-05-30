'use strict';

angular.module('appApp').controller('apiTokenInstanceCtrl', ["$uibModalInstance", "id", "apiTokenService", function ($uibModalInstance, id, apiTokenService) {
  var $ctrl = this;
  $ctrl.id = id;
  $ctrl.tokens = {};
  $ctrl.rateLimit = "";
  $ctrl.rateWindow = "";
  $ctrl.tokenLimit = "";
  $ctrl.tokenWindow = "";

  apiTokenService.getApiTokens(id).success(function(data) {
    data.forEach(token => {
      $ctrl.tokens[token.id] = token;
    })
    $ctrl.empty = _.isEmpty($ctrl.tokens);
  })

  $ctrl.toggleEditForm = function (id) {
    if (id) {
      const token = $ctrl.tokens[id];
      $ctrl.tokenLimit = token.rate_limit;
      $ctrl.tokenWindow = token.rate_window;
    } else {
      $ctrl.tokenLimit = "";
      $ctrl.tokenWindow = "";
    }
    $ctrl.currentlyEditing = id;
  }

  $ctrl.updateToken = function (id, data) {
    apiTokenService.updateToken(id, data)
      .success(function(data) {
        $ctrl.tokens[data.id] = data;
        $ctrl.currentlyEditing = null;
        apiTokenService.toast('token-update-success');
      })
      .error(function() {
        apiTokenService.toast('token-update-failure');
      })
  }

  $ctrl.generateToken = function(rateLimit, rateWindow) {
    apiTokenService.generateToken($ctrl.id, rateLimit, rateWindow)
      .success(function(data) {
        $ctrl.tokens[data.id] = data;
        $ctrl.empty = false;
        $ctrl.rateLimit = "";
        $ctrl.rateWindow = "";
        apiTokenService.toast('token-create-success');
      })
      .error(function() {
        apiTokenService.toast('token-create-failure');
      })
  }

  $ctrl.deleteToken = function (id) {
    apiTokenService.deleteToken(id)
      .success(function(data) {
        delete $ctrl.tokens[data.id];
        $ctrl.empty = _.isEmpty($ctrl.tokens);
        apiTokenService.toast('token-delete-success');
      })
      .error(function() {
        apiTokenService.toast('token-delete-failure');
      })
  }
}])
