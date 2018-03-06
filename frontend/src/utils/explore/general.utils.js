import _ from 'lodash';
import { selectMap } from './models.utils';

export function formatResults (data, params, count) {
  const {
    page_settings: { page_size: pageSize },
    sort: { fields },
    select: { object: resultType },
  } = params;
  const result = {};

  result.results = Object.values(data.pages)[0].map(x => addItemType(x));
  result.pageNum = parseInt(Object.keys(data.pages)[0], 10);
  result.pageSize = pageSize;
  result.resultsCount = count;
  result.sort = convertToTableSort(fields);
  result.resultType = resultType;

  return result;
}

export function addItemType (app) {
  return {
    ...app,
    type: app.platform === 'ios' ? 'IosApp' : 'AndroidApp',
  };
}

export const convertToTableSort = (sorts) => {
  const tableSorts = [];
  const strippedSorts = sorts.slice(0, sorts.length - 2);
  strippedSorts.forEach((sort) => {
    const sortName = getSortName(sort.field);
    if (sortName && sortName !== 'Platform') {
      tableSorts.push({
        id: getSortName(sort.field),
        desc: sort.order === 'desc',
      });
    }
  });

  return tableSorts;
};

export const getSortName = (val) => {
  for (const key in selectMap) {
    if (selectMap[key]) {
      const fields = selectMap[key];
      if (fields && fields.includes(val) && fields[0] === val) {
        return key;
      }
    }
  }

  return null;
};

export function panelFilterCount(filters, panelKey) {
  if (panelKey === '1') {
    return filters.sdks.filters.filter(x => x.sdks.length > 0).length;
  }

  return Object.values(filters).filter(x => x.panelKey === panelKey && x.displayText && x.displayText.length > 0).length;
}

export function hasFilters(filters) {
  const keys = Object.keys(cleanState({ filters }).filters);
  const sdks = filters.sdks;
  return keys.length > 1 || sdks.filters.some(x => x.sdks.length > 0);
}

export function cleanState (form) {
  const cleanedState = _.cloneDeep(form);
  const sdkFilters = cleanedState.filters.sdks.filters;

  if (sdkFilters.length > 1) {
    _.remove(sdkFilters, x => x.sdks.length === 0);
  }

  cleanedState.filters.sdks.filters = sdkFilters.map((x) => {
    const newFilter = { ...x };
    if (['never-seen', 'is-installed', 'is-not-installed'].includes(x.eventType)) {
      newFilter.dateRange = 'anytime';
      newFilter.dates = [];
    }
    return newFilter;
  });

  if (cleanedState.filters.availableCountries && cleanedState.filters.availableCountries.value.countries.length === 0) {
    delete cleanedState.filters.availableCountries;
  };

  return cleanedState;
}
