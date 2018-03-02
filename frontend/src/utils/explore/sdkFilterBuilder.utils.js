import _ from 'lodash';
import { requirePlatformFilter } from './queryBuilder.utils';

export function buildSdkFilters ({ sdks }) {
  const result = {
    operator: sdks.operator === 'and' ? 'intersect' : 'union',
    inputs: [],
  };

  sdks.filters.forEach((filter) => {
    const sdkFilter = generateSdkFilter(filter);
    if (sdkFilter) {
      result.inputs.push(sdkFilter);
    }
  });

  if (result.inputs.length === 0) {
    return null;
  }

  return result;
}

export function generateSdkFilter (filter) {
  if (filter.sdks.length === 0) {
    return null;
  }

  const query = {
    operator: filter.operator === 'all' ? 'intersect' : 'union',
    inputs: [],
  };

  const dateItem = generateDateRange(filter);

  const sdkTemplate = (sdk) => {
    const typeItem = generateTypeItem(filter.eventType);
    const sdkItem = generateSdkItem(sdk, filter.eventType);
    const filterObject = ['is-installed', 'is-not-installed'].includes(filter.eventType) ? 'sdk' : 'sdk_event';

    let sdkFilter = {
      object: filterObject,
      operator: 'filter',
      predicates: _.compact([
        typeItem,
        dateItem,
        sdkItem,
        ['platform', sdk.platform],
      ]),
    };

    if (filter.eventType === 'never-seen') {
      sdkFilter = {
        operator: 'not',
        inputs: [sdkFilter],
      };
    }

    // return sdkFilter;
    return requirePlatformFilter(sdkFilter, sdk.platform);
  };

  filter.sdks.forEach(sdk => query.inputs.push(sdkTemplate(sdk)));

  return query;
}

export function generateSdkItem (sdk, eventType) {
  const result = [];
  const base = ['is-installed', 'is-not-installed'].includes(eventType) ? 'id' : 'sdk_id';
  result.push(`${base}${sdk.sdks ? 's' : ''}`);
  result.push(sdk.sdks ? sdk.sdks : sdk.id);

  return result;
}

export function generateTypeItem (eventType) {
  switch (eventType) {
    case 'uninstall':
      return ['type', 'uninstall'];
    case 'is-installed':
      return ['installed'];
    case 'is-not-installed':
      return ['not', ['installed']];
    default:
      return ['type', 'install'];
  }
}

export function generateDateRange ({ dateRange, dates, eventType }) {
  if (dateRange === 'anytime' || ['never-seen', 'is-installed', 'is-not-installed'].includes(eventType)) {
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
      break;
    default:
      break;
  }

  return result;
}
