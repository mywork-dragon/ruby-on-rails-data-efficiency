import { headerNames } from 'Table/redux/column.models';

// map between frontend display fields and backend field
// place sort field at beginning of the list
export const selectMap = {
  [headerNames.APP]: [
    'name',
    'id',
    'current_version',
    'icon_url',
    'taken_down',
    'app_identifier',
    'first_scanned_date',
    'price_category',
    'original_release_date',
    'in_app_purchases',
  ],
  [headerNames.COUNTRIES_AVAILABLE_IN]: ['countries_available_in'],
  [headerNames.FIRST_SEEN_ADS]: ['ad_summaries'],
  [headerNames.LAST_SEEN_ADS]: ['ad_summaries'],
  [headerNames.LAST_UPDATED]: ['current_version_release_date'],
  [headerNames.MOBILE_PRIORITY]: ['mobile_priority'],
  [headerNames.PLATFORM]: ['platform'],
  [headerNames.PUBLISHER]: ['publisher'],
  [headerNames.RATING]: ['all_version_rating'],
  [headerNames.RATINGS_COUNT]: ['all_version_ratings_count'],
  [headerNames.USER_BASE]: ['user_base', 'international_user_bases'],
  [headerNames.AD_NETWORKS]: ['ad_summaries'],
  [headerNames.CATEGORY]: ['categories'],
  [headerNames.DOWNLOADS]: ['downloads'],
};

export const sortMap = {
  [headerNames.APP]: { field: 'name', object: 'app' },
  // [headerNames.CATEGORY]: { field: 'name', object: 'app_category' },
  [headerNames.DOWNLOADS]: { field: 'downloads_min', object: 'app' },
  [headerNames.FIRST_SEEN_ADS]: { field: 'first_seen_ads_date', object: 'mobile_ad_data_summary', function: 'min' },
  [headerNames.LAST_SEEN_ADS]: { field: 'last_seen_ads_date', object: 'mobile_ad_data_summary', function: 'max' },
  [headerNames.LAST_UPDATED]: { field: 'current_version_release_date', object: 'app' },
  [headerNames.MOBILE_PRIORITY]: { field: 'current_version_release_date', object: 'app' },
  [headerNames.PUBLISHER]: { field: 'name', object: 'publisher' },
  [headerNames.RATING]: { field: 'all_version_rating', object: 'app' },
  [headerNames.RATINGS_COUNT]: { field: 'all_version_ratings_count', object: 'app' },
  [headerNames.RELEASE_DATE]: { field: 'original_release_date', object: 'app' },
};

export const csvSelect = (facebookOnly) => {
  const baseFields = {
    name: true,
    id: true,
    app_identifier: true,
    platform: true,
    mobile_priority: true,
    original_release_date: true,
    current_version_release_date: true,
    in_app_purchases: true,
    category_names: true,
    publisher_id: true,
    publisher_name: true,
    all_version_rating: true,
    all_version_ratings_count: true,
    downloads: true,
    ad_attribution_sdks: true,
    mightysignal_app_page: true,
    mightysignal_publisher_page: true,
    user_base: true,
    user_base_us: true,
    user_base_br: true,
    user_base_fr: true,
    user_base_au: true,
    user_base_kr: true,
    user_base_ru: true,
    user_base_il: true,
    user_base_jp: true,
    user_base_gb: true,
    user_base_cn: true,
    user_base_de: true,
  };

  let fields;

  if (facebookOnly) {
    fields = {
      ...baseFields,
      has_fb_ad_spend: true,
    };
  } else {
    fields = {
      ...baseFields,
      ad_network_names: true,
      first_seen_ads: true,
      last_seen_ads: true,
    };
  }

  return {
    object: 'app',
    fields: {
      app: fields,
    },
  };
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
  adNetworkCount: 'count_advertising_networks',
  ratingsCount: 'all_version_ratings_count',
  rating: 'all_version_rating',
  releaseDate: 'released',
  downloads: 'downloaded',
};

export const publisherFilterKeys = {
  fortuneRank: 'fortune_rank',
  headquarters: 'country_code',
};

export const adIntelFilterKeys = {
  creativeFormats: '',
};
