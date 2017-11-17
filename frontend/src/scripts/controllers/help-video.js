import angular from 'angular';
import mixpanel from 'mixpanel-browser';

angular.module('appApp')
  .controller("VideoModalCtrl", ["$scope", "$uibModal", function($scope, $uibModal) {

    $scope.openVideoModal = function (type) {
      $uibModal.open({
        animation: true,
        ariaLabelledBy: 'videoModalTitle',
        ariaDescribedBy: 'videoModalBody',
        template: require('../../components/help-video/help-video.html'), // this is messed up...two different places relying on same controller
        controller: 'VideoInstanceCtrl',
        controllerAs: '$ctrl',
        size: 'lg',
        resolve: {
          type: function () {
            return type;
          }
        }
      })

      mixpanel.track("Help Video Opened", {
        videoType: type
      });

    }
  }])
  .controller('VideoInstanceCtrl', ['$uibModalInstance', '$sce', 'type', function ($uibModalInstance, $sce, type) {
    var $ctrl = this;
    $ctrl.videoUrls = {
      'Timeline': 'https://www.youtube.com/embed/gtqkNxgpyZk',
      'Explore': 'https://www.youtube.com/embed/aQ-H79xbeAg',
      'Ad Intelligence': 'https://www.youtube.com/embed/jp9c3xyqHOc',
      'Live Scan': 'https://www.youtube.com/embed/h1mDtcHsQ1Q'
    }

    $ctrl.type = type;
    $ctrl.videoUrl = $sce.trustAsResourceUrl($ctrl.videoUrls[type]);
  }])
