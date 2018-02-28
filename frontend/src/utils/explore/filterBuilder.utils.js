import { snakeCase } from 'utils/format.utils';
import { appFilterKeys, publisherFilterKeys } from './models.utils';
import { buildSdkFilters } from './sdkFilterBuilder.utils';

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
    if (appFilterKeys.includes(key) && filters[key].value.length <= 2) { // TODO: we'll see how this holds, meant to eliminate unnecessary filters
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  return result;
}

export function buildPublisherFilters ({ filters }) {
  const result = {
    operator: 'filter',
    predicates: [],
    object: 'publisher',
  };

  for (const key in filters) {
    if (publisherFilterKeys.includes(key)) {
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  if (result.predicates.length === 0) {
    return null;
  }

  return result;
}

function generatePredicate(type, filter) {
  const result = ['or'];
  const filterType = snakeCase(type);
  if (Array.isArray(filter.value)) {
    filter.value.forEach((x) => {
      result.push([
        filterType,
        x,
      ]);
    });
  } else if (typeof filter.value === 'number') {
    result.push([
      filterType,
      0,
      filter.value,
    ]);
  }

  return result;
}
