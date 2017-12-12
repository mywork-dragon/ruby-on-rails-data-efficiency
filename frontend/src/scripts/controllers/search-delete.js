import angular from 'angular';

angular
  .module('appApp')
  .controller('ModalInstanceCtrl', ModalInstanceCtrl)

ModalInstanceCtrl.$inject = ['$uibModalInstance', 'id']

function ModalInstanceCtrl ($uibModalInstance, id) {
  var $ctrl = this;
  $ctrl.id = id;

  $ctrl.ok = function () {
    $uibModalInstance.close();
  };

  $ctrl.cancel = function () {
    $uibModalInstance.dismiss('cancel');
  };
};
