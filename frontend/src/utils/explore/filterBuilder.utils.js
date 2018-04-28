import _ from 'lodash';
import * as models from './models.utils';
import { buildSdkFilters } from './sdkFilterBuilder.utils';
import { requirePlatformFilter } from './queryBuilder.utils';
import { generateQueryDateRange } from './general.utils';

export function buildFilter (form) {
  const result = {
    filter: {
      operator: 'intersect',
      inputs: [],
    },
  };

  const appFilters = buildAppFilters(form);
  const sdkFilters = buildSdkFilters(form.filters);
  const publisherFilters = buildPublisherFilters(form);
  const adIntelFilters = buildAdIntelFilters(form.filters);
  const adNetworkFilters = buildAdNetworkFilters(form);

  if (appFilters) {
    result.filter.inputs.push(appFilters);
  }

  if (publisherFilters) {
    result.filter.inputs.push(publisherFilters);
  }

  if (adIntelFilters) {
    result.filter.inputs.push(adIntelFilters);
  }

  if (sdkFilters) {
    result.filter.inputs.push(sdkFilters);
  }

  if (adNetworkFilters) {
    result.filter.inputs.push(adNetworkFilters);
  }

  if (form.filters.iosCategories || form.filters.androidCategories) {
    result.filter.inputs.push(buildCategoryFilters(form.filters));
  }

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
    if (models.isAppFilter(key) || (key === 'adNetworkCount' && resultType === 'app')) {
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
    if (models.isPubFilter(key) || (key === 'adNetworkCount' && resultType === 'publisher')) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  return result;
}

export function buildCategoryFilters (filters) {
  const result = {
    operator: 'union',
    inputs: [],
  };

  if (filters.iosCategories) {
    result.inputs.push(requirePlatformFilter(buildPlatformCategoryFilter(filters.iosCategories, 'ios'), 'ios'));
  }

  if (filters.androidCategories) {
    result.inputs.push(requirePlatformFilter(buildPlatformCategoryFilter(filters.androidCategories, 'android'), 'android'));
  }

  return result;
}

export function buildPlatformCategoryFilter (filter, platform) {
  const result = {
    operator: 'filter',
    object: 'app_category',
    predicates: [
      ['platform', platform],
    ],
  };

  const ids = ['or'];

  filter.value.forEach(x => ids.push(['id', x.value]));
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
    if (models.isAdIntelFilter(key)) {
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

export function buildRankingsFilters (form) {
  return {};
}

// TODO: clean this up someday
function generatePredicate(type, { value, value: { operator, condition } }) {
  const result = [];
  result.push(operator && operator === 'all' ? 'and' : 'or');
  const filterType = models.getQueryFilter(type);
  if (Array.isArray(value)) {
    if (value.length === 0) {
      return null;
    }
    value.forEach((x) => {
      const n = [];
      let val = x;
      if (type === 'headquarters') {
        val = x.key;
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
  } else if (type === 'ratingsCount' || type === 'rating' || type === 'downloads' || type === 'adNetworkCount') {
    if (value.value.every(x => !x)) {
      return null;
    }

    const values = value.value.slice();

    if (value.operator === 'less-than') values[0] = null;

    const filter = [filterType].concat(values);

    if (type === 'downloads') {
      return [
        'or',
        filter,
        ['platform', 'ios'],
      ];
    }

    return filter;
  } else if (type === 'releaseDate') {
    return generateQueryDateRange('released', value.dateRange, value.dates);
  }

  return result;
}
