import { headerNames } from 'Table/redux/column.models';

// map between frontend display fields and backend field
// place sort field at beginning of the list
export const selectMap = {
  [headerNames.APP]: ['name', 'id', 'current_version', 'icon_url', 'taken_down', 'app_identifier', 'first_scanned_date'],
  [headerNames.COUNTRIES_AVAILABLE_IN]: ['countries_available_in'],
  [headerNames.LAST_UPDATED]: ['last_updated'],
  [headerNames.MOBILE_PRIORITY]: ['mobile_priority'],
  [headerNames.PLATFORM]: ['platform'],
  [headerNames.PUBLISHER]: ['publisher'],
  [headerNames.RATINGS]: ['all_version_rating', 'all_version_ratings_count'],
  [headerNames.USER_BASE]: ['user_base'],
};

export const isAppFilter = filter => Object.keys(appFilterKeys).includes(filter);
export const isPubFilter = filter => Object.keys(publisherFilterKeys).includes(filter);
export const isAdIntelFilter = filter => Object.keys(adIntelFilterKeys).includes(filter);
export const getQueryFilter = filter => Object.assign({}, appFilterKeys, publisherFilterKeys, adIntelFilterKeys)[filter];

export const appFilterKeys = {
  availableCountries: 'available_in',
  mobilePriority: 'mobile_priority',
  userBase: 'user_base',
  price: 'free',
  inAppPurchases: 'in_app_purchases',
};

export const publisherFilterKeys = {
  fortuneRank: 'fortune_rank',
  headquarters: 'country_code',
};

export const adIntelFilterKeys = {
  creativeFormats: '',
};
