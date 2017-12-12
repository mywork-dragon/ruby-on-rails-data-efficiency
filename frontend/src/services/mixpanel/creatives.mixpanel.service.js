import angular from 'angular';
import mixpanel from 'mixpanel-browser';

angular
  .module('appApp')
  .service('creativesMixpanelService', creativesMixpanelService);

creativesMixpanelService.$inject = ['$stateParams'];

function creativesMixpanelService($stateParams) {
  const service = {
    trackCreativeClick,
    trackCreativePageThrough,
    trackCreativeScroll,
  };

  return service;

  function trackCreativeClick(creative, hasApps) {
    mixpanel.track('Creative Clicked', {
      format: creative.format,
      network: creative.ad_network,
      app_identifier: creative.app_identifier,
      platform: creative.platform,
      id: $stateParams.id,
      pageType: hasApps ? 'publisher' : 'app',
    });
  }

  function trackCreativePageThrough(page, hasApps) {
    mixpanel.track('Creatives Paged Through', {
      pageNum: page,
      id: $stateParams.id,
      platform: $stateParams.platform,
      pageType: hasApps ? 'publisher' : 'app',
    });
  }

  function trackCreativeScroll(hasApps) {
    mixpanel.track('Creatives Scrolled Through', {
      id: $stateParams.id,
      platform: $stateParams.platform,
      pageType: hasApps ? 'publisher' : 'app',
    });
  }
}
