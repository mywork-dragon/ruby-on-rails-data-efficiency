import _ from 'lodash';
import { headerNames } from 'Table/redux/column.models';
import { getNestedValue } from 'utils/format.utils';
import { generateQueryDateRange, validRankingsFilter } from './general.utils';

export function buildSelect (form, columns, accountNetworks) {
  const fields = [];
  const columnNames = Object.keys(columns);

  const selects = selectMap(form.resultType);

  columnNames.forEach((column) => {
    if (selects[column]) {
      selects[column].forEach(field => fields.push(field));
    }
  });

  const facebookOnly = accountNetworks.length === 1 && accountNetworks[0].id === 'facebook';

  const mappedFields = {};

  _.uniq(fields).forEach((field) => {
    if (['ad_summaries', 'ad_networks', 'first_seen_ads', 'last_seen_ads'].includes(field) && facebookOnly) {
      mappedFields[field] = ['facebook'];
    } else if (field === 'rankings') {
      const rankingsSelect = buildRankingsSelect(form);
      mappedFields.rankings = rankingsSelect.rankings;
      mappedFields.newcomers = rankingsSelect.newcomers;
    } else {
      mappedFields[field] = true;
    }
  });

  const result = {
    fields: {
      [form.resultType]: mappedFields,
    },
    object: form.resultType,
  };

  return result;
}

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

export const csvSelect = (facebookOnly, resultType, form) => {
  let fields = {
    name: true,
    id: true,
    platform: true,
  };

  const rankingsParams = buildRankingsSelect(form);

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
      min_rank_value: rankingsParams.rankings,
      min_rank_chart: rankingsParams.rankings,
      max_rank_value: rankingsParams.rankings,
      max_rank_chart: rankingsParams.rankings,
      min_weekly_change_value: rankingsParams.rankings,
      min_weekly_change_chart: rankingsParams.rankings,
      max_weekly_change_value: rankingsParams.rankings,
      max_weekly_change_chart: rankingsParams.rankings,
      min_monthly_change_value: rankingsParams.rankings,
      min_monthly_change_chart: rankingsParams.rankings,
      max_monthly_change_value: rankingsParams.rankings,
      max_monthly_change_chart: rankingsParams.rankings,
      earliest_newcomer_value: rankingsParams.newcomers,
      earliest_newcomer_chart: rankingsParams.newcomers,
      latest_newcomer_value: rankingsParams.newcomers,
      latest_newcomer_chart: rankingsParams.newcomers,
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

function buildRankingsSelect (form) {
  const result = {
    rankings: {},
    newcomers: {},
  };
  const defaultFilter = {
    countries: ['US', 'FR', 'CA', 'CN', 'BR', 'AU', 'UK', 'SP', 'IT', 'DE', 'SE', 'RU', 'KR', 'JP', 'CH', 'SG', 'NL', 'AR'].join(','),
    charts: 'free',
    categories: [],
    dateRange: { value: 'two-week' },
    eventType: { value: null },
    values: [],
    operator: null,
    trendOperator: null,
  };

  const rankingsFilter = getNestedValue(['filters', 'rankings'], form);

  const filter = validRankingsFilter(rankingsFilter) ? rankingsFilter.value : defaultFilter;

  const {
    countries = '',
    charts,
    categories,
    eventType,
    dateRange,
    values,
    operator,
    trendOperator,
  } = filter;

  if (countries) result.rankings.countries = countries.split(',');
  if (charts) result.rankings.ranking_types = charts.split(',');
  if (categories.length) {
    result.rankings.categories = _.compact(_.flatten(categories.map(x => [x.ios, x.android])));
  }
  if (form.platform !== 'all') result.rankings.platform = [form.platform];
  if (eventType.value === 'rank') {
    result.newcomers.created_at = generateQueryDateRange('created_at', 'two-week')[1];
    if (operator === 'less-than') values[0] = null;
    if (operator === 'between') {
      result.rankings.rank = values;
    } else {
      result.rankings.rank = values.slice().reverse();
    }
  } else if (eventType.value === 'trend') {
    result.newcomers.created_at = generateQueryDateRange('created_at', 'two-week')[1];
    let vals = values.slice();
    if (trendOperator === 'down') {
      vals = vals.reverse();
      vals = vals.map((x) => {
        if (typeof x === 'number' && x > 0) {
          return -x;
        } else if (operator === 'less-than') {
          return 0;
        }
        return x;
      });
    }
    if (dateRange.value === 'week') {
      result.rankings.weekly_change = vals;
    } else if (dateRange.value === 'month') {
      result.rankings.monthly_change = vals;
    }
  } else if (eventType.value === 'newcomer') {
    result.newcomers.created_at = generateQueryDateRange('created_at', dateRange.value)[1];
  } else if (!eventType.value) {
    result.newcomers.created_at = generateQueryDateRange('created_at', 'two-week')[1];
  }

  result.newcomers = { ...result.rankings, ...result.newcomers };

  return result;
}
