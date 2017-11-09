(function() {
  'use strict';

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
    '$sce'
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
    $sce
  ) {
    var adIntel = this;

    adIntel.adNetworks = {};
    adIntel.appFetchComplete = false;
    adIntel.apps = [];
    adIntel.category = 'first_seen_ads_date';
    adIntel.csvUrl = '';
    adIntel.currentPage = 1;
    adIntel.enabledNetworkCount = 0;
    adIntel.modalNetwork;
    adIntel.networkCount = 0;
    adIntel.numApps = 0;
    adIntel.order = 'desc';
    adIntel.platform = 'all';
    adIntel.platforms = {'all': 'All', 'ios': 'iOS', 'android': 'Android'}
    adIntel.rowSort = '-first_seen_ads_date';

    adIntel.calculateDaysAgo = calculateDaysAgo;
    adIntel.checkIfAdSource = checkIfAdSource;
    adIntel.expandTotalContainer = expandTotalContainer;
    adIntel.formatCategories = formatCategories;
    adIntel.getApps = getApps;
    adIntel.getDaysAgoClass = getDaysAgoClass;
    adIntel.shrinkTotalContainer = shrinkTotalContainer;
    adIntel.sortApps = sortApps;
    adIntel.toggleAdNetwork = toggleAdNetwork;
    adIntel.togglePlatform = togglePlatform;
    adIntel.trackCsvExport = adIntelMixpanelService.trackCsvExport;
    adIntel.trackItemClick = adIntelMixpanelService.trackItemClick;
    adIntel.trackPageThrough = adIntelMixpanelService.trackPageThrough;

    activate();

    function activate() {
      getAdNetworks()
      .then(function() {
        getApps()
      })
      adIntelMixpanelService.trackAdIntelView(adIntel.platform)
      pageTitleService.setTitle('MightySignal - Ad Intelligence')
    }

    function checkIfAdSource (id, sources) {
      return sources.some(source => source.id == id)
    }

    function expandTotalContainer () {
      $("#advertiser-total").width("143px")
      $("#advertiser-total").height("160px")
      $("#advertiser-total > .advertiser-csv-btn").css("visibility", "visible")
    }

    function formatCategories (app) {
      let categoryString = ""
      if (app.platform == 'android') {
        categoryString = app.categories[0].name || "";
      } else if (app.platform == 'ios' && app.categories.length) {
        categoryString = app.categories.find(cat => cat.type == 'primary').name;
      }
      return categoryString;
    }

    function getActiveAdNetworks () {
      return Object.values(adIntel.adNetworks).filter(network => network.active).map(network => network.id)
    }

    function getAdNetworks () {
      return adIntelService.getAdSources()
        .then(function(data) {
          adIntel.adNetworks = data;
          adIntel.enabledNetworkCount = Object.values(data).filter(network => network.can_access).length;
          adIntel.networkCount = Object.values(data).length;
        })
    }

    function getApps (page = adIntel.currentPage, category = adIntel.category, order = adIntel.order) {
      adIntel.appFetchComplete = false;
      resetTable(page, category, order)
      const activeAdNetworks = getActiveAdNetworks()
      adIntelService.getAdIntelApps(adIntel.platform, page, order, category, activeAdNetworks)
        .then(function(response) {
          if (response.status == 200) {
            const data = response.data;
            adIntel.apps = data.results;
            adIntel.numApps = data.resultsCount;
            adIntel.currentPage = data.pageNum;
            $rootScope.currentPage = data.pageNum;
            $rootScope.numApps = data.resultsCount;
            $rootScope.numPerPage = data.pageSize;
          } else {
            adIntel.numApps = 0;
            $rootScope.numApps = 0;
          }

          adIntel.appFetchComplete = true;
          updateCSVUrl();
        })
    }

    function getDaysAgoClass (days) {
      return searchService.getLastUpdatedDaysClass(days);
    };

    function calculateDaysAgo (date) {
      return sdkLiveScanService.calculateDaysAgo(date).split(' ago')[0];
    };

    function resetTable (page = 1, category = 'first_seen_ads_date', order = 'desc') {
      adIntel.apps = [];
      adIntel.category = category;
      adIntel.currentPage = page;
      adIntel.order = order;
      const sign = order == 'desc' ? '-' : '';
      adIntel.rowSort = sign + category;
    }

    function shrinkTotalContainer () {
      $("#advertiser-total").width("120px")
      $("#advertiser-total").height("115px")
      $("#advertiser-total > .advertiser-csv-btn").css("visibility", "hidden")
    }

    function sortApps (category, order) {
      getApps(1, category, order)
      adIntelMixpanelService.trackTableSortChange(category, order, adIntel.platform)
    }

    function toggleAdNetwork (id) {
      const network = adIntel.adNetworks[id]
      if (!network) {
        adIntel.modalNetwork = null;
      } else if (network.can_access) {
        resetTable()
        getApps()
      } else {
        adIntel.modalNetwork = network;
      }
      adIntelMixpanelService.trackAdNetworkToggle(id, adIntel.platform)
    }

    function togglePlatform (platform) {
      adIntel.platform = platform
      resetTable()
      getApps()
      adIntelMixpanelService.trackAdIntelView(platform)
    }

    function updateCSVUrl () {
      const platforms = adIntel.platform == 'all' ? ['ios', 'android'] : [adIntel.platform];
      var params = {
        "pageNum": 1,
        "pageSize": 100000,
        "sourceIds": JSON.stringify(getActiveAdNetworks()),
        "platforms": JSON.stringify(platforms),
        "access_token": authToken.get()
      };
      adIntel.csvUrl = API_URI_BASE + 'api/ad_intelligence/v2/query.csv?' + jQuery.param(params)
    }
  }
})();
