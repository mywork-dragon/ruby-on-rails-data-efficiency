import _ from 'lodash';

import { getMaxDate, getMinDate } from './format.utils';

export function formatPublisherAdData (data) {
  const result = {
    number_of_creatives: 0,
    creative_formats: [],
    ad_networks: [],
    ad_attribution_sdks: [],
    total_apps: Object.keys(data).length,
    advertising_apps: [],
  };
  Object.keys(data).forEach((key) => {
    const app = data[key];
    result.number_of_creatives += app.number_of_creatives;
    result.creative_formats = _.union(result.creative_formats, app.creative_formats);
    result.first_seen_ads_date = getMinDate(result.first_seen_ads_date, app.first_seen_ads_date);
    result.last_seen_ads_date = getMaxDate(result.last_seen_ads_date, app.last_seen_ads_date);
    app.ad_networks.forEach((network) => {
      const existingNetwork = result.ad_networks.find(x => x.id === network.id);
      if (existingNetwork) {
        existingNetwork.first_seen_ads_date = getMinDate(existingNetwork.first_seen_ads_date, network.first_seen_ads_date);
        existingNetwork.last_seen_ads_date = getMaxDate(existingNetwork.last_seen_ads_date, network.last_seen_ads_date);
        existingNetwork.number_of_creatives += network.number_of_creatives;
        existingNetwork.creative_formats = _.union(existingNetwork.creative_formats, network.creative_formats);
      } else {
        result.ad_networks.push(network);
      }
    });
    app.ad_attribution_sdks.forEach((sdk) => {
      if (!result.ad_attribution_sdks.some(x => x.id === sdk.id)) { result.ad_attribution_sdks.push(sdk); }
    });
    result.advertising_apps.push(Object.assign(app, { id: key }));
  });

  result.advertising_apps = _.sortBy(result.advertising_apps, app => app.last_seen_ads_date).reverse();

  return result;
}

export function formatPublisherCreatives (data) {
  const result = Object.assign({}, data);
  if (data.results.constructor === Object && Object.keys(data.results).length === 0) {
    result.results = [];
  }
  return result;
}
