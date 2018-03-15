import _ from 'lodash';
import { requirePlatformFilter } from './queryBuilder.utils';
import { generateQueryDateRange } from './general.utils';

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
    const filterObject = ['is-installed', 'is-not-installed'].includes(filter.eventType) && !sdk.sdks ? 'sdk' : 'sdk_event';

    let sdkFilter = {
      object: filterObject,
      operator: 'filter',
      predicates: _.compact([
        typeItem,
        dateItem,
        sdkItem,
      ]),
    };

    if (!sdk.sdks) {
      sdkFilter.predicates.push(['platform', sdk.platform]);
    }

    if (['never-seen', 'is-not-installed'].includes(filter.eventType)) {
      sdkFilter = {
        operator: 'not',
        inputs: [sdkFilter],
      };
    }

    return requirePlatformFilter(sdkFilter, sdk.platform);
  };

  filter.sdks.forEach(sdk => query.inputs.push(sdkTemplate(sdk)));

  return query;
}

export function generateSdkItem (sdk, eventType) {
  if (sdk.sdks) {
    const result = [
      'sdk_category',
      sdk.name,
      sdk.platform,
    ];
    const excluded = _.difference(sdk.sdks.map(x => x[0]), sdk.includedSdks.map(x => x[0]));
    if (excluded.length > 0) {
      result.push(excluded);
    }
    return result;
  }
  return [
    ['is-installed', 'is-not-installed'].includes(eventType) ? 'id' : 'sdk_id',
    sdk.id,
  ];
}

export function generateTypeItem (eventType) {
  switch (eventType) {
    case 'uninstall':
      return ['type', 'uninstall'];
    case 'is-installed':
    case 'is-not-installed':
      return ['installed'];
    default:
      return ['type', 'install'];
  }
}

export function generateDateRange ({ dateRange, dates, eventType }) {
  if (['never-seen', 'is-installed', 'is-not-installed'].includes(eventType)) {
    return null;
  }

  return generateQueryDateRange('date', dateRange, dates);
}
