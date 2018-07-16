import { subtractDays } from 'utils/format.utils';

export function formatAppAdData (data) {
  return Object.values(data)[0];
}

export function formatAppCreatives (data) {
  const result = Object.assign({}, data);
  const results = Object.values(data.results);
  result.results = results.length ? results[0].creatives : [];
  return result;
}

export function addAdIds (ads) {
  if (ads) {
    for (let i = 0; i < ads.length; i++) {
      const ad = ads[i];
      ad.id = i;
    }
  }
  return ads;
}

export function formatRankingsParams (options) {
  const params = {};
  params.countries = JSON.stringify(options.countries);
  params.platform = options.platform;
  params.app_identifier = options.appIdentifier;
  params.max_date = new Date();
  params.min_date = subtractDays(options.dateRange);

  if (options.categories.length) params.categories = options.categories.split(',');
  if (options.rankingTypes.length) params.rank_types = options.rankingTypes.split(',');

  return params;
}
