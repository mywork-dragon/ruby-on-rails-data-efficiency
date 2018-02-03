import angular from 'angular';
import $ from 'jquery';
import { $localStorage } from 'utils/localStorage.utils';

import 'directives/fallback-src.directive';
import 'AngularMixpanel/ad-intelligence.mixpanel.service';
import 'components/export-permissions/export-permissions.directive';
import './components/new-ad-intel-modal/new-ad-intel.directive';


const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .controller('AdIntelligenceController', AdIntelligenceController);

AdIntelligenceController.$inject = [
  'pageTitleService',
  'adIntelService',
  '$rootScope',
  '$location',
  'authToken',
  'searchService',
  'sdkLiveScanService',
  'adIntelMixpanelService',
];

function AdIntelligenceController(
  pageTitleService,
  adIntelService,
  $rootScope,
  $location,
  authToken,
  searchService,
  sdkLiveScanService,
  adIntelMixpanelService,
) {
  const adIntel = this;

  adIntel.adNetworks = {};
  adIntel.appFetchComplete = false;
  adIntel.apps = [];
  adIntel.category = 'first_seen_ads_date';
  adIntel.csvUrl = '';
  adIntel.currentPage = 1;
  adIntel.enabledNetworkCount = 0;
  adIntel.error = false;
  adIntel.modalNetwork;
  adIntel.networkCount = 0;
  adIntel.numApps = 0;
  adIntel.order = 'desc';
  adIntel.platform = 'all';
  adIntel.platforms = { all: 'All', ios: 'iOS', android: 'Android' };
  adIntel.rowSort = '-first_seen_ads_date';

  adIntel.calculateDaysAgo = calculateDaysAgo;
  adIntel.checkIfAdSource = checkIfAdSource;
  adIntel.formatCategories = formatCategories;
  adIntel.getApps = getApps;
  adIntel.getDaysAgoClass = getDaysAgoClass;
  adIntel.getNetworkIcon = getNetworkIcon;
  adIntel.sortApps = sortApps;
  adIntel.toggleAdNetwork = toggleAdNetwork;
  adIntel.togglePlatform = togglePlatform;
  adIntel.trackCsvExport = adIntelMixpanelService.trackCsvExport;
  adIntel.trackItemClick = adIntelMixpanelService.trackItemClick;
  adIntel.trackPageThrough = adIntelMixpanelService.trackPageThrough;

  activate();

  function activate() {
    getAdNetworks()
      .then(() => {
        getApps();
      });
    adIntelMixpanelService.trackAdIntelView(adIntel.platform);
    pageTitleService.setTitle('MightySignal - Ad Intelligence');
  }

  function checkIfAdSource (id, sources) {
    return sources.some(source => source.id === id);
  }

  function formatCategories (app) {
    let categoryString = '';
    if (app.categories.length === 0) {
      return 'Not available';
    }
    if (app.platform === 'android') {
      categoryString = app.categories[0].name || '';
    } else if (app.platform === 'ios' && app.categories.length) {
      categoryString = app.categories.find(cat => cat.type === 'primary').name;
    }
    return categoryString;
  }

  function getActiveAdNetworks () {
    const activeNetworks = Object.values(adIntel.adNetworks).filter(network => network.active).map(network => network.id);
    $localStorage.set('activeAdNetworks', activeNetworks);
    return activeNetworks;
  }

  function getAdNetworks () {
    return adIntelService.getAdSources()
      .then((data) => {
        adIntel.adNetworks = data;
        const activeNetworks = $localStorage.get('activeAdNetworks');
        if (activeNetworks) {
          for (let key in adIntel.adNetworks) {
            if (Object.prototype.hasOwnProperty.call(adIntel.adNetworks, key)) {
              const network = adIntel.adNetworks[key];
              network.active = activeNetworks.includes(network.id) && network.can_access;
            }
          }
        }
        adIntel.enabledNetworkCount = Object.values(data).filter(network => network.can_access).length;
        adIntel.networkCount = Object.values(data).length;
      });
  }

  function getApps (page = adIntel.currentPage, category = adIntel.category, order = adIntel.order) {
    adIntel.appFetchComplete = false;
    resetTable(page, category, order);
    const activeAdNetworks = getActiveAdNetworks();
    adIntelService.getAdIntelApps(adIntel.platform, page, order, category, activeAdNetworks)
      .then((response) => {
        const data = response.data;
        adIntel.apps = data.results;
        adIntel.numApps = data.resultsCount;
        adIntel.currentPage = data.pageNum;
        $rootScope.currentPage = data.pageNum;
        $rootScope.numApps = data.resultsCount;
        $rootScope.numPerPage = data.pageSize;
        adIntel.appFetchComplete = true;
        updateCSVUrl();
      })
      .catch(() => {
        adIntel.numApps = 0;
        $rootScope.numApps = 0;
        adIntel.appFetchComplete = true;
        adIntel.error = true;
        updateCSVUrl();
      });
  }

  function getDaysAgoClass (days) {
    return searchService.getLastUpdatedDaysClass(days);
  }

  function getNetworkIcon (network) {
    let icon = `images/${network.id}.png`;
    if (network.active && network.id === 'applovin') {
      icon = 'images/applovin-inverted.png';
    } else if (network.active && network.id === 'mopub') {
      icon = 'images/mopub-inverted.png';
    }
    return icon;
  }

  function calculateDaysAgo (date) {
    return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0];
  }

  function resetTable (page = 1, category = 'first_seen_ads_date', order = 'desc') {
    adIntel.apps = [];
    adIntel.category = category;
    adIntel.currentPage = page;
    adIntel.order = order;
    const sign = order === 'desc' ? '-' : '';
    adIntel.rowSort = sign + category;
  }

  function sortApps (category, order) {
    getApps(1, category, order);
    adIntelMixpanelService.trackTableSortChange(category, order, adIntel.platform);
  }

  function toggleAdNetwork (id) {
    const network = adIntel.adNetworks[id];
    if (!network) {
      adIntel.modalNetwork = null;
    } else if (network.can_access) {
      resetTable();
      getApps();
    } else {
      adIntel.modalNetwork = network;
    }
    adIntelMixpanelService.trackAdNetworkToggle(id, adIntel.platform);
  }

  function togglePlatform (platform) {
    adIntel.platform = platform;
    resetTable();
    getApps();
    adIntelMixpanelService.trackAdIntelView(platform);
  }

  function updateCSVUrl () {
    const platforms = adIntel.platform === 'all' ? ['ios', 'android'] : [adIntel.platform];
    const params = {
      pageNum: 1,
      pageSize: 100000,
      sourceIds: JSON.stringify(getActiveAdNetworks()),
      platforms: JSON.stringify(platforms),
      access_token: authToken.get(),
    };
    adIntel.csvUrl = `${API_URI_BASE}api/ad_intelligence/v2/query.csv?${$.param(params)}`;
  }
}
