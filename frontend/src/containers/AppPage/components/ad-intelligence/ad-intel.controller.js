import angular from 'angular';
import _ from 'lodash';

import 'Mixpanel/app.mixpanel.service';
import 'services/app.service';
import 'components/ad-intelligence/creative-gallery/creative-gallery.directive';
import 'components/ad-intelligence/ad-network-panel/ad-network-panel.directive';
import 'components/ad-intelligence/ad-summary-panel/ad-summary-panel.directive';

angular
  .module('appApp')
  .controller('AppAdIntelligenceController', AppAdIntelligenceController);

AppAdIntelligenceController.$inject = [
  '$state',
  '$stateParams',
  'appService',
  'appMixpanelService',
  '$scope',
];

function AppAdIntelligenceController(
  $state,
  $stateParams,
  appService,
  appMixpanelService,
  $scope,
) {
  const appAdIntel = this;

  appAdIntel.adDataFetchComplete = false;
  appAdIntel.creativePageSize = 8;
  appAdIntel.error = false;
  appAdIntel.getCreatives = appService.getAppCreatives;
  appAdIntel.hasAdData = false;

  activate();

  function activate() {
    if ($scope.$parent.$parent.app.facebookOnly) {
      $state.go('app.info', { platform: $stateParams.platform, id: $stateParams.id });
    } else {
      appAdIntel.id = $stateParams.id;
      appAdIntel.platform = $stateParams.platform;
      getAdIntelData();
      appMixpanelService.trackAppPageView($scope.$parent.$parent.app);
    }
  }

  function getAdIntelData () {
    return appService.getAdIntelData($stateParams.platform, $stateParams.id)
      .then((response) => {
        const data = response.data;
        if (!_.isEmpty(data)) {
          Object.assign(appAdIntel, data[$stateParams.id]);
          appAdIntel.hasAdData = true;
        }
        appAdIntel.adDataFetchComplete = true;
      })
      .catch(() => {
        appAdIntel.error = true;
        appAdIntel.adDataFetchComplete = true;
      });
  }
}
