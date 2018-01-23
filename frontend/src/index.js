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
require('AngularService/api.js');
require('AngularService/auth.js');
require('AngularService/general.js');
require('AngularService/filter.js');
require('AngularService/search.js');
require('AngularService/sdk-search.js');
require('AngularService/sdk-live-scan.js');
require('AngularService/saved-search.js');
require('AngularService/click-copy.js');
require('AngularService/contact.service.js');
require('AngularService/custom-search.js');
require('AngularService/list.js');

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

/* Admin Scripts */
require('containers/AdminPage/admin.controller.js');

/* Ad Intelligence Scripts */
require('containers/AdIntelligencePage/ad-intelligence.controller.js');

/* Custom Search Scripts */
require('containers/CustomSearchPage/custom-search');
require('containers/CustomSearchPage/sdk-search');

/* Explore Scripts */
require('containers/ExplorePage/search');
require('containers/ExplorePage/explore-page.directive');

/* Login Scripts */
require('containers/LoginPage/login');

/* Popular Apps Scripts */
require('containers/PopularAppsPage/popular-apps.js');
require('containers/PopularAppsPage/top-chart.js');

/* Publisher Component Scripts */
require('containers/PublisherPage/publisher.controller.js');

/* SDK Page Scripts */
require('containers/SdkPage/sdk-details');

/* Timeline Scripts */
require('containers/TimelinePage/newsfeed');

/* Directives */
require('directives/directives.js');

/* Utils */
require('AngularUtils/csv.utils.js');
