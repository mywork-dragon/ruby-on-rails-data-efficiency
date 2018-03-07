import _ from 'lodash';
import * as models from './models.utils';
import { buildSdkFilters } from './sdkFilterBuilder.utils';
import { requirePlatformFilter } from './queryBuilder.utils';

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

  if (appFilters) {
    result.filter.inputs.push(appFilters);
  }

  if (publisherFilters) {
    result.filter.inputs.push(publisherFilters);
  }

  if (sdkFilters) {
    result.filter.inputs.push(sdkFilters);
  }

  if (form.filters.iosCategories || form.filters.androidCategories) {
    result.filter.inputs.push(buildCategoryFilters(form.filters));
  }

  return result;
}

export function buildAppFilters ({ platform, includeTakenDown, filters }) {
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
    if (models.isAppFilter(key)) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  result.predicates = _.compact(result.predicates);

  return result;
}

export function buildPublisherFilters ({ filters }) {
  const result = {
    operator: 'filter',
    predicates: [],
    object: 'publisher',
  };

  for (const key in filters) {
    if (models.isPubFilter(key)) {
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

  filter.value.forEach(x => ids.push(['id', x]));
  result.predicates.push(ids);

  return result;
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
      let val = x;
      if (type === 'headquarters') {
        val = x.key;
      }
      result.push([
        filterType,
        val,
      ]);
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
      return ['only_available_in_country', value.countries[0].key];
    }

    value.countries.forEach((x) => {
      const predicate = ['available_in', x.key];
      if (condition === 'available-in') {
        result.push(predicate);
      } else {
        result.push(['not', predicate]);
      }
    });
  } else if (['price', 'inAppPurchases'].includes(type)) {
    if (['paid', 'no'].includes(value)) {
      return ['not', [filterType]];
    }
    return [filterType];
  }

  return result;
}
