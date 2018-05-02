import { headerNames } from 'Table/redux/column.models';

// map between frontend display fields and backend field
// place sort field at beginning of the list
export const selectMap = (type) => {
  if (type === 'app') {
    return {
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
      [headerNames.RANK]: ['rankings'],
    };
  } else if (type === 'publisher') {
    return {
      [headerNames.AD_NETWORKS]: ['ad_networks'],
      [headerNames.DOWNLOADS]: ['total_downloads'],
      [headerNames.FIRST_SEEN_ADS]: ['first_seen_ads'],
      [headerNames.FORTUNE_RANK]: ['companies'],
      [headerNames.LAST_SEEN_ADS]: ['last_seen_ads'],
      [headerNames.LAST_UPDATED]: ['last_app_update_date'],
      [headerNames.NUM_APPS]: ['number_of_apps'],
      [headerNames.PUBLISHER]: ['name', 'publisher_identifier', 'domains', 'id', 'icon_url', 'companies'],
      [headerNames.PLATFORM]: ['platform'],
      [headerNames.RATING]: ['average_ratings'],
      [headerNames.RATINGS_COUNT]: ['total_ratings'],
    };
  }

  return null;
};

export const sortMap = (resultType) => {
  const sorts = {
    [headerNames.PUBLISHER]: { field: 'name', object: 'publisher' },
  };

  if (resultType === 'app') {
    return {
      ...sorts,
      [headerNames.APP]: { field: 'name', object: 'app' },
      [headerNames.DOWNLOADS]: { field: 'downloads_min', object: 'app' },
      [headerNames.FIRST_SEEN_ADS]: { field: 'first_seen_ads_date', object: 'mobile_ad_data_summary', function: 'min' },
      [headerNames.LAST_SEEN_ADS]: { field: 'last_seen_ads_date', object: 'mobile_ad_data_summary', function: 'max' },
      [headerNames.LAST_UPDATED]: { field: 'current_version_release_date', object: 'app' },
      [headerNames.MOBILE_PRIORITY]: { field: 'current_version_release_date', object: 'app' },
      [headerNames.RATING]: { field: 'all_version_rating', object: 'app' },
      [headerNames.RATINGS_COUNT]: { field: 'all_version_ratings_count', object: 'app' },
      [headerNames.RELEASE_DATE]: { field: 'original_release_date', object: 'app' },
    };
  } else if (resultType === 'publisher') {
    return {
      ...sorts,
      [headerNames.DOWNLOADS]: { field: 'downloads_min', object: 'app', function: 'sum' },
      [headerNames.FIRST_SEEN_ADS]: { field: 'first_seen_ads_date', object: 'mobile_ad_data_summary' },
      [headerNames.LAST_SEEN_ADS]: { field: 'last_seen_ads_date', object: 'mobile_ad_data_summary' },
      [headerNames.LAST_UPDATED]: { field: 'current_version_release_date', object: 'app', function: 'max' },
      [headerNames.NUM_APPS]: { field: 'id', object: 'app', function: 'count' },
      [headerNames.RATING]: { field: 'average_rating', object: 'app' },
      [headerNames.RATINGS_COUNT]: { field: 'all_version_ratings_count', object: 'app', function: 'sum' },
    };
  }

  return null;
};

export const csvSelect = (facebookOnly, resultType) => {
  let fields = {
    name: true,
    id: true,
    platform: true,
  };

  if (resultType === 'app') {
    fields = {
      ...fields,
      app_identifier: true,
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

    if (facebookOnly) {
      fields = {
        ...fields,
        has_fb_ad_spend: true,
      };
    } else {
      fields = {
        ...fields,
        ad_network_names: true,
        first_seen_ads: true,
        last_seen_ads: true,
      };
    }
  } else if (resultType === 'publisher') {
    fields = {
      ...fields,
      total_downloads: true,
      number_of_apps: true,
      average_ratings: true,
      total_ratings: true,
      last_app_update_date: true,
      mightysignal_publisher_page: true,
    };

    if (!facebookOnly) {
      fields = {
        ...fields,
        ad_networks: true,
        first_seen_ads: true,
        last_seen_ads: true,
      };
    } else if (facebookOnly) {
      fields = {
        ...fields,
        ad_networks: ['facebook'],
      };
    }
  }

  return {
    object: resultType,
    fields: {
      [resultType]: fields,
    },
  };
};

export const isAppFilter = filter => Object.keys(appFilterKeys).includes(filter);
export const isPubFilter = filter => Object.keys(publisherFilterKeys).includes(filter);
export const isAdIntelFilter = filter => Object.keys(adIntelFilterKeys).includes(filter);
export const getQueryFilter = filter => Object.assign({}, appFilterKeys, publisherFilterKeys, adIntelFilterKeys, rankingsFilterKeys, sharedFilterKeys)[filter];

export const appFilterKeys = {
  availableCountries: 'available_in',
  mobilePriority: 'mobile_priority',
  userBase: 'user_base',
  price: 'free',
  inAppPurchases: 'in_app_purchases',
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

export const rankingsFilterKeys = {
  countries: 'country',
  charts: 'ranking_type',
  rank: 'rank',
  newcomer: 'created_at',
  trend_week: 'weekly_change',
  trend_month: 'monthly_change',
};

export const sharedFilterKeys = {
  adNetworkCount: 'count_advertising_networks',
};
