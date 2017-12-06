/* Include all the 3rd party code */
require('./vendors')

/*
 * CSS
 *
*/

require('./styles/font-awesome/css/font-awesome.css')
require('./styles/main.css');
require('./styles/flags.css');
require('./styles/ng-tags-input.css');

/*
 * JS
 *
*/

/* Custom Angular Scripts */
require('./scripts/app.js');
require('./scripts/services/api.js');
require('./scripts/services/auth.js');
require('./scripts/services/general.js');
require('./scripts/services/filter.js');
require('./scripts/services/search.js');
require('./scripts/services/newsfeed.js');
require('./scripts/services/sdk-search.js');
require('./scripts/services/sdk-live-scan.js');
require('./scripts/services/saved-search.js');
require('./scripts/services/api-token.js');
require('./scripts/services/app.service.js');
require('./scripts/services/publisher.service.js');
require('./scripts/services/popular-apps.service.js');
require('./scripts/services/click-copy.js');
require('./scripts/services/contact.service.js');
require('./scripts/services/ad-intelligence.service.js');
require('./ad-intelligence/adIntelMixpanel.service.js');
require('./scripts/services/custom-search.js');
require('./scripts/services/list.js');
require('./scripts/controllers/main.js');
require('./scripts/controllers/filter.js');
require('./scripts/controllers/search.js');
require('./scripts/controllers/custom-search.js');
require('./scripts/controllers/list.js');
require('./scripts/controllers/login.js');
require('./scripts/controllers/sdk-search.js');
require('./scripts/controllers/chart.js');
require('./scripts/controllers/newsfeed.js');
require('./scripts/controllers/company-details.js');
require('./scripts/controllers/sdk-details.js');
require('./scripts/controllers/admin.js');
require('./scripts/controllers/charts.js');
require('./scripts/controllers/table.controller.js');
require('./ad-intelligence/ad-intelligence.controller.js');
require('./scripts/controllers/popular-apps.js');
require('./scripts/controllers/top-chart.js');
require('./scripts/controllers/modal-search.js');
require('./scripts/controllers/search-delete.js');
require('./scripts/controllers/help-video.js');
require('./scripts/controllers/api-token.js');
require('./scripts/utils/csv.utils.js');

/* App Component Scripts */
require('./apps/android-live-scan.js');
require('./apps/app.controller.js');
require('./apps/ios-live-scan.js');
require('./apps/ad-intel.controller.js');

/* Publisher Component Scripts */
require('./publishers/publisher.controller.js');
require('./publishers/ad-intel.controller.js');

/* Directives */
require('./scripts/directives/directives.js');
require('./scripts/directives/fallback-src.directive.js');
