import angular from 'angular';
import _ from 'lodash';

import './appMixpanel.service.js';
import '../scripts/directives/fallback-src.directive'
import '../components/creative-gallery/creative-gallery.directive'
import '../scripts/directives/format-icon.directive'

angular
  .module('appApp')
  .controller('AppAdIntelligenceController', AppAdIntelligenceController);

AppAdIntelligenceController.$inject = [
  '$state',
  '$stateParams',
  'appService',
  'appMixpanelService',
  '$scope'
];

function AppAdIntelligenceController(
  $state,
  $stateParams,
  appService,
  appMixpanelService,
  $scope
) {
  var appAdIntel = this;

  appAdIntel.adDataFetchComplete = false;
  appAdIntel.creativePageSize = 8;
  appAdIntel.getCreatives = appService.getAppCreatives;
  appAdIntel.hasAdData = false;

  activate();

  function activate() {
    if ($scope.$parent.$parent.app.facebookOnly) {
      $state.go('app.info', { platform: $stateParams.platform, id: $stateParams.id })
    } else {
      appAdIntel.id = $stateParams.id
      appAdIntel.platform = $stateParams.platform
      getAdIntelData()
      appMixpanelService.trackAppPageView($scope.$parent.$parent.app)
    }
  }

  function getAdIntelData () {
    return appService.getAdIntelData($stateParams.platform, $stateParams.id)
      .then(function(data) {
        if (!_.isEmpty(data)) {
          Object.assign(appAdIntel, data[$stateParams.id])
          appAdIntel.hasAdData = true;
        }
        appAdIntel.adDataFetchComplete = true;
      })
  }
}
