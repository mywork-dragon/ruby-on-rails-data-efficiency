/* Include all the 3rd party code */
require('./vendors');

/*
 * CSS
 *
*/

require('./styles/font-awesome/css/font-awesome.css');
require('./styles/main.css');
require('./styles/flags.css');
require('./styles/ng-tags-input.css');

/*
 * JS
 *
*/

/* Custom Angular Scripts */
require('./scripts/app.js');

/* Service Scripts */
require('services/api.js');
require('services/auth.js');
require('services/general.js');
require('services/filter.js');
require('services/search.js');
require('services/sdk-search.js');
require('services/sdk-live-scan.js');
require('services/saved-search.js');
require('services/click-copy.js');
require('services/contact.service.js');
require('services/custom-search.js');
require('services/list.js');

/* Controller Scripts */
require('./scripts/controllers/main.js');
require('./scripts/controllers/filter.js');
require('./scripts/controllers/list.js');
require('./scripts/controllers/table.controller.js');
require('./scripts/controllers/modal-search.js');
require('./scripts/controllers/search-delete.js');

/* App Component Scripts */
require('containers/AppPage/app.controller.js');
require('containers/AppPage/components/android-live-scan/android-live-scan.js');
require('containers/AppPage/components/ios-live-scan/ios-live-scan.js');
require('containers/AppPage/components/ad-intelligence/ad-intel.controller.js');

/* Admin Scripts */
require('containers/AdminPage/admin.controller.js');

/* Ad Intelligence Scripts */
require('containers/AdIntelligencePage/ad-intelligence.controller.js');

/* Custom Search Scripts */
require('containers/CustomSearchPage/custom-search');
require('containers/CustomSearchPage/sdk-search');

/* Explore Scripts */
require('containers/ExplorePage/search');

/* Login Scripts */
require('containers/LoginPage/login');

/* Popular Apps Scripts */
require('containers/PopularAppsPage/popular-apps.js');
require('containers/PopularAppsPage/top-chart.js');

/* Publisher Component Scripts */
require('containers/PublisherPage/publisher.controller.js');
require('containers/PublisherPage/components/ad-intelligence/ad-intel.controller.js');

/* SDK Page Scripts */
require('containers/SdkPage/sdk-details');

/* Timeline Scripts */
require('containers/TimelinePage/newsfeed');

/* Directives */
require('directives/directives.js');

/* Utils */
require('utils/csv.utils.js');
