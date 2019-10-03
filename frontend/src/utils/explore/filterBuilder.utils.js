import _ from 'lodash';
import * as filterKeys from './filterKeys.utils';
import { buildSdkFilters } from './sdkFilterBuilder.utils';
import { requirePlatformFilter } from './queryBuilder.utils';
import { generateQueryDateRange, validRankingsFilter } from './general.utils';

export function buildFilter (form) {
  const result = {
    filter: {
      operator: 'intersect',
      inputs: [],
    },
  };

  result.filter.inputs.push(buildAppFilters(form));
  result.filter.inputs.push(buildPublisherFilters(form));
  result.filter.inputs.push(buildAdIntelFilters(form.filters));
  result.filter.inputs.push(buildSdkFilters(form.filters));
  result.filter.inputs.push(buildAdNetworkFilters(form));
  result.filter.inputs.push(buildRankingsFilters(form));
  result.filter.inputs.push(buildCategoryFilters(form));
  result.filter.inputs.push(buildHeadquarterFilters(form.filters));
  result.filter.inputs = _.compact(result.filter.inputs);

  return result;
}

export function buildAppFilters ({ resultType, platform, includeTakenDown, filters }) {
  const result = {
    operator: 'filter',
    predicates: [],
    object: 'app',
  };

  if (platform !== 'all') {
    result.predicates.push([
      'platform',
      platform,
    ]);
  }

  if (!includeTakenDown) {
    result.predicates.push([
      'not',
      [
        'taken_down',
      ],
    ]);
  }

  for (const key in filters) {
    if (filterKeys.isAppFilter(key) || (key === 'adNetworkCount' && resultType === 'app')) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  result.predicates = _.compact(result.predicates);

  return result;
}

export function buildPublisherFilters ({ resultType, filters }) {
  const result = {
    operator: 'filter',
    predicates: [],
    object: 'publisher',
  };

  for (const key in filters) {
    if (filterKeys.isPubFilter(key) || (key === 'adNetworkCount' && resultType === 'publisher')) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  return result;
}

export function buildCategoryFilters ({ platform, filters }) {
  if (!filters.categories) return null;
  const result = {
    operator: 'union',
    inputs: [],
  };

  const iosCategories = filters.categories.value.filter(x => x.ios);
  if (iosCategories.length && platform !== 'android') {
    result.inputs.push(requirePlatformFilter(buildPlatformCategoryFilter(iosCategories, 'ios'), 'ios'));
  }

  const androidCategories = filters.categories.value.filter(x => x.android);
  if (androidCategories.length && platform !== 'ios') {
    result.inputs.push(requirePlatformFilter(buildPlatformCategoryFilter(androidCategories, 'android'), 'android'));
  }

  return result;
}

export function buildPlatformCategoryFilter (categories, platform) {
  const result = {
    operator: 'filter',
    object: 'app_category',
    predicates: [
      ['platform', platform],
    ],
  };

  const ids = ['or'];

  categories.forEach(x => ids.push(['id', x[platform]]));
  result.predicates.push(ids);

  return result;
}

export function buildAdIntelFilters (filters) {
  const result = {
    operator: 'filter',
    object: 'mobile_ad_data_summary',
    predicates: [],
  };

  for (const key in filters) {
    if (filterKeys.isAdIntelFilter(key)) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  return result;
}

export function buildAdNetworkFilters ({ resultType, filters: { adNetworks: adNetworksFilter } }) {
  if (!adNetworksFilter || adNetworksFilter.value.adNetworks.length === 0) {
    return null;
  }

  const {
    adNetworks,
    operator,
    firstSeenDateRange,
    firstSeenDate,
    lastSeenDateRange,
    lastSeenDate,
  } = adNetworksFilter.value;

  const generateAppFilter = () => {
    const networks = adNetworks.map(x => x.key);
    let predicates = [
      generateQueryDateRange('first_seen_ads_date', firstSeenDateRange, firstSeenDate),
      generateQueryDateRange('last_seen_ads_date', lastSeenDateRange, lastSeenDate),
    ];

    predicates = _.compact(predicates);
    predicates.forEach(x => x.push(networks));

    return {
      operator: 'filter',
      object: resultType,
      predicates,
    };
  };

  const hasDateRange = firstSeenDateRange !== 'anytime' || lastSeenDateRange !== 'anytime';

  if (hasDateRange && operator === 'any') {
    return generateAppFilter();
  }

  const result = {
    operator: operator === 'all' ? 'intersect' : 'union',
    inputs: [],
  };

  adNetworks.forEach((network) => {
    const filter = {
      operator: 'filter',
      object: 'mobile_ad_data_summary',
      predicates: [
        ['ad_network', network.key],
      ],
    };

    result.inputs.push(filter);
  });

  if (hasDateRange) {
    result.inputs.push(generateAppFilter());
  }

  return result;
}

export function buildRankingsFilters ({ platform, filters }) {
  if (!filters || !filters.rankings || !validRankingsFilter(filters.rankings)) return null;

  const { rankings } = filters;

  const {
    eventType: {
      value: eventType,
    },
    dateRange,
    values,
    categories = [],
  } = rankings.value;

  rankings.value.value = values.slice();

  const result = {
    operator: 'filter',
    object: eventType === 'newcomer' ? 'newcomer' : 'ranking',
    predicates: [],
  };

  if (platform !== 'all') {
    result.predicates.push(['platform', platform]);
  }

  ['countries', 'charts'].forEach((x) => {
    const value = rankings.value[x];
    if (value && value.length) {
      const predicate = ['or'];
      const key = filterKeys.getQueryFilter(x);
      value.split(',').forEach(y => (predicate.push([key, y])));
      result.predicates.push(predicate);
    }
  });

  if (categories.length) {
    const categoryPredicate = ['or'];
    categories.forEach((category) => {
      if (category.ios && platform !== 'android') categoryPredicate.push(['category', category.ios]);
      if (category.android && platform !== 'ios') categoryPredicate.push(['category', category.android]);
    });

    if (categoryPredicate.length > 1) result.predicates.push(categoryPredicate);
  }

  switch (eventType) {
    case 'rank':
      result.predicates.push(generatePredicate('rank', rankings));
      break;
    case 'newcomer':
      if (dateRange) {
        result.predicates.push(generatePredicate('newcomer', rankings));
      }
      break;
    case 'trend':
      result.predicates.push(generatePredicate(`trend_${dateRange.value}`, rankings));
  }

  return result;
}

export function buildHeadquarterFilters ({ headquarters }) {
  if (headquarters && headquarters.value.values.length) {
    const { values, operator, includeNoHqData } = headquarters.value;
    const result = {
      operator: operator === 'any' ? 'union' : 'intersect',
      inputs: [],
    };

    values.forEach((location) => {
      const filter = {
        operator: 'filter',
        object: 'publisher',
        predicates: [],
      };

      const {
        city,
        state,
        country,
      } = location;

      filter.predicates.push(_.compact([
        'and',
        city ? ['city', city] : null,
        state ? ['state_code', state] : null,
        country ? ['country_code', country] : null,
      ]));

      if (operator === 'any') {
        result.inputs.push(filter);
      } else if (operator === 'none') {
        result.inputs.push({
          operator: 'not',
          inputs: [filter],
        });
      }
    });

    if (includeNoHqData) {
      return {
        operator: 'union',
        inputs: [
          result,
          {
            operator: 'not',
            inputs: [
              {
                operator: 'filter',
                predicates: [
                  ['not', ['country_code_is_null']],
                ],
                object: 'domain_data',
              },
            ],
          },
        ],
      };
    }

    return result;
  }

  return null;
}

// TODO: clean this up someday
function generatePredicate(type, { value, value: { operator, condition } }) {
  const result = [];
  result.push(operator && operator === 'all' ? 'and' : 'or');
  const filterType = filterKeys.getQueryFilter(type);
  if (Array.isArray(value)) {
    if (value.length === 0) {
      return null;
    }
    value.forEach((x) => {
      const n = [];
      let val = x;
      if (type === 'headquarters') {
        val = x.key;
      } else if (type === 'appPermissions') {
        val = x.value;
      }
      if (filterType.length > 0) {
        n.push(filterType);
      }
      n.push(val);
      result.push(n);
    });
  } else if (typeof value === 'number') {
    result.push([
      filterType,
      0,
      value,
    ]);
  } else if (type === 'availableCountries') {
    if (value.countries.length === 0) {
      return;
    }

    if (!condition || condition === 'only-available-in') {
      return [
        'or',
        ['only_available_in_country', value.countries[0].key],
        ['platform', 'android'],
      ]
    }

    value.countries.forEach((x) => {
      const predicate = ['available_in', x.key];
      if (condition === 'available-in') {
        result.push(predicate);
      } else {
        result.push(['not', predicate]);
      }
    });

    if (operator === 'any') {
      result.push(['platform', 'android']);
    } else {
      return [
        'or',
        result,
        ['platform', 'android'],
      ];
    }

  } else if (['price', 'inAppPurchases'].includes(type)) {
    if (['paid', 'no'].includes(value)) {
      return ['not', [filterType]];
    }
    return [filterType];
  } else if (['ratingsCount', 'rating', 'downloads', 'mau_change', 'adNetworkCount', 'rank', 'trend_week', 'trend_month'].includes(type)) {
    if (value.value.every(x => !x && typeof x !== 'number')) {
      return null;
    }

    let values = value.value.slice().map(x => (typeof x === 'number' ? x : null));

    if (value.operator === 'less-than' && !['trend_week', 'trend_month'].includes(type)) values[0] = null;

    if (type === 'rank' && value.operator !== 'between') values = values.reverse();

    if (['trend_week', 'trend_month'].includes(type) && value.trendOperator === 'down') {
      values = values.reverse();
      values = values.map((x) => {
        if (typeof x === 'number' && x > 0) {
          return -x;
        } else if (value.operator === 'less-than') {
          return 0;
        }
        return x;
      });
    }

    const filter = [filterType].concat(values);

    if (type === 'downloads' || type === 'mau_change') {
      return [
        'or',
        filter,
        ['platform', 'ios'],
      ];
    }

    return filter;
  } else if (['releaseDate', 'newcomer'].includes(type)) {
    if (type === 'newcomer') {
      return generateQueryDateRange(filterType, value.dateRange.value);
    }
    return generateQueryDateRange(filterType, value.dateRange, value.dates);
  }

  return result;
}
