import { snakeCase } from 'utils/format.utils';
import { appFilterKeys, publisherFilterKeys } from './models.utils';

export function buildFilter (form) {
  const result = {
    filter: {
      operator: 'intersect',
      inputs: [],
    },
  };

  const appFilters = buildAppFilters(form);
  const sdkFilters = buildSdkFilters(form);
  const publisherFilters = buildPublisherFilters(form);

  if (appFilters.predicates.length !== 0) {
    result.filter.inputs.push(appFilters);
  }

  if (publisherFilters.predicates.length !== 0) {
    result.filter.inputs.push(publisherFilters);
  }

  if (sdkFilters.inputs.length !== 0) {
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

  for (let key in filters) {
    if (appFilterKeys.includes(key) && filters[key].value.length <= 2) { // TODO: we'll see how this holds, meant to eliminate unnecessary filters
      result.predicates.push(generatePredicate(key, filters[key]));
    }
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

export function buildSdkFilters (filters) {
  return {
    operator: 'union',
    inputs: [
      {
        operator: 'filter',
        predicates: [
          [
            'type',
            'install',
          ],
          [
            'sdk_id',
            200,
          ],
        ],
        object: 'sdk_event',
      },
      {
        operator: 'filter',
        predicates: [
          [
            'type',
            'install',
          ],
          [
            'sdk_id',
            114,
          ],
        ],
        object: 'sdk_event',
      },
    ],
  };
}

export function buildPublisherFilters ({ filters }) {
  const result = {
    operator: 'filter',
    predicates: [],
    object: 'publisher',
  };

  for (let key in filters) {
    if (publisherFilterKeys.includes(key)) { // TODO: we'll see how this holds, meant to eliminate unnecessary filters
      result.predicates.push(generatePredicate(key, filters[key]));
    }
  }

  return result;
}
