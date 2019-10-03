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
  mau_change: 'mau_change',
  appPermissions: 'has_permission',
};

export const publisherFilterKeys = {
  fortuneRank: 'fortune_rank',
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
