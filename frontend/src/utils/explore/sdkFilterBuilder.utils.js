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

  const sdkTemplate = (sdk, installState) => {
    const typeItem = generateTypeItem(installState || filter.eventType);
    const sdkItem = generateSdkItem(sdk, installState || filter.eventType);
    const objectItem = installState && !sdk.sdks ? 'sdk' : 'sdk_event';

    let sdkFilter = {
      object: objectItem,
      operator: 'filter',
      predicates: _.compact([
        typeItem,
        installState ? null : dateItem,
        sdkItem,
      ]),
    };

    if (!sdk.sdks) {
      sdkFilter.predicates.push(['platform', sdk.platform]);
    }

    if (['never-seen', 'is-not-installed'].includes(installState || filter.eventType)) {
      sdkFilter = {
        operator: 'not',
        inputs: [sdkFilter],
      };
    }


    if (!installState) {
      sdkFilter = requirePlatformFilter(sdkFilter, sdk.platform);

      if (filter.eventType !== 'never-seen' && filter.installState !== 'any-installed') {
        sdkFilter.inputs.push(sdkTemplate(sdk, filter.installState));
      }
    }

    return sdkFilter;
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
    const excluded = _.difference(sdk.sdks.map(x => x.id), sdk.includedSdks.map(x => x.id));
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
