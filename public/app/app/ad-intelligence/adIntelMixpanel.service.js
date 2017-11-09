(function() {
  'use strict';

  angular
    .module('appApp')
    .service('adIntelMixpanelService', adIntelMixpanelService);

  adIntelMixpanelService.$inject = [];

  function adIntelMixpanelService() {
    var service = {
      trackAdIntelView,
      trackAdNetworkToggle,
      trackCsvExport,
      trackItemClick,
      trackPageThrough,
      trackTableSortChange
    }

    return service;

    function trackAdIntelView (platform) {
      mixpanel.track('Ad Intelligence Viewed', {
        platform
      })
    }

    function trackAdNetworkToggle (network, platform) {
      mixpanel.track('Ad Network Toggled', {
        network,
        platform
      })
    }

    function trackCsvExport(platform) {
      mixpanel.track("Ad Intelligence Exported", {
        platform
      })
    }

    function trackItemClick (item, type, platform) {
      mixpanel.track(
        "Ad Intelligence Item Clicked", {
          "name": item.name,
          "id": item.id,
          platform,
          type
        }
      )
    }

    function trackPageThrough (page, platform) {
      mixpanel.track("Ad Intelligence Paged Through", {
        page,
        platform
      })
    }

    function trackTableSortChange (category, order, platform) {
      mixpanel.track("Ad Intelligence Table Sorting Changed", {
        category,
        order,
        "appPlatform": platform
      })
    }
  }
})();
