import _ from 'lodash';

export function buildSdkFilters ({ sdks }) {
  const result = {
    operator: sdks.operator === 'and' ? 'intersect' : 'union',
    inputs: [],
  };

  sdks.filters.forEach((filter) => {
    if (filter.sdks.length === 0) {
      return;
    }

    const query = {
      operator: filter.operator === 'all' ? 'intersect' : 'union',
      inputs: [],
    };

    const dateItem = generateDateRange(filter);

    const sdkTemplate = (sdk) => {
      const sdkItem = generateSdkItem(sdk);
      const sdkFilter = {
        object: 'sdk_event',
        operator: 'filter',
        predicates: _.compact([
          ['type', filter.eventType === 'uninstall' ? 'uninstall' : 'install'],
          dateItem,
          sdkItem,
          ['platform', sdk.platform],
        ]),
      };

      if (filter.eventType === 'never-seen') {
        return {
          operator: 'not',
          inputs: [sdkFilter],
        };
      }

      return sdkFilter;
    };

    filter.sdks.forEach(sdk => query.inputs.push(sdkTemplate(sdk)));
    result.inputs.push(query);
  });

  if (result.inputs.length === 0) {
    return null;
  }

  return result;
}

export function generateDateRange ({ dateRange, dates }) {
  if (dateRange === 'anytime') {
    return null;
  }

  let result = ['date'];
  switch (dateRange) {
    case 'week':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { days: 7 }]],
        ['utcnow'],
      ]);
      break;
    case 'month':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { months: 1 }]],
        ['utcnow'],
      ]);
      break;
    case 'three-months':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { months: 3 }]],
        ['utcnow'],
      ]);
      break;
    case 'six-months':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { months: 6 }]],
        ['utcnow'],
      ]);
      break;
    case 'year':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { years: 1 }]],
        ['utcnow'],
      ]);
      break;
    case 'custom':
      dates.forEach(x => result.push(x));
    default:
      break;
  }

  return result;
}

export function generateSdkItem (sdk) {
  const result = [];
  result.push(`sdk_id${sdk.sdks ? 's' : ''}`);
  result.push(sdk.sdks ? sdk.sdks : sdk.id);

  return result;
}
