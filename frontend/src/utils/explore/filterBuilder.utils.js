import { snakeCase } from 'utils/format.utils';
import { appFilterKeys } from './models.utils';

export function buildFilter (form) {
  const result = {
    filter: {
      operator: 'intersect',
      inputs: [],
    },
  };

  const appFilters = buildAppFilters(form);
  const sdkFilters = buildSdkFilters(form);

  if (appFilters.predicates.length !== 0) {
    result.filter.inputs.push(appFilters);
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
  filter.value.forEach((x) => {
    result.push([
      filterType,
      x,
    ]);
  });

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
