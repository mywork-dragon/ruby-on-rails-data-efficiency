import angular from 'angular';

angular.module('appApp').controller('ModalInstanceCtrl', function ($uibModalInstance, id) {
  var $ctrl = this;
  $ctrl.id = id;

  $ctrl.ok = function () {
    $uibModalInstance.close();
  };

  $ctrl.cancel = function () {
    $uibModalInstance.dismiss('cancel');
  };
});
