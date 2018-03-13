
import _ from 'lodash';
import { capitalize, getMaxDate, getMinDate } from 'utils/format.utils';
import { selectMap } from './models.utils';

export function formatResults (data, params, count) {
  const {
    page_settings: { page_size: pageSize },
    sort: { fields },
    select: { object: resultType },
  } = params;
  const result = {};

  result.results = Object.values(data.pages)[0].map(x => formatApp(x));
  result.pageNum = parseInt(Object.keys(data.pages)[0], 10);
  result.pageSize = pageSize;
  result.resultsCount = count;
  result.sort = convertToTableSort(fields);
  result.resultType = resultType;

  return result;
}

function formatApp (app) {
  return {
    ...app,
    ...(addItemType(app)),
    categories: formatCategories(app.categories),
    ...formatAdintelInfo(app),
  };
}

function formatCategories (categories) {
  if (categories.length === 1) {
    return categories.map(x => x.name);
  }

  const primary = categories.find(x => x.type === 'primary');
  const secondary = categories.find(x => x.type === 'secondary');

  return [`${primary.name} (${secondary.name})`];
}

export function addItemType (app) {
  return {
    ...app,
    type: app.platform === 'ios' ? 'IosApp' : 'AndroidApp',
  };
}

function formatAdintelInfo ({ ad_summaries }) {
  const result = {
    ad_networks: [],
    first_seen_ads_date: null,
    last_seen_ads_date: null,
    creative_formats: [],
    adSpend: !ad_summaries,
  };

  if (ad_summaries) {
    ad_summaries.forEach((summary) => {
      result.ad_networks.push({ id: summary.ad_network });
      result.first_seen_ads_date = result.first_seen_ads_date ? getMinDate(result.first_seen_ads_date, summary.first_seen_ads_date) : summary.first_seen_ads_date;
      result.last_seen_ads_date = result.last_seen_ads_date ? getMaxDate(result.last_seen_ads_date, summary.last_seen_ads_date) : summary.last_seen_ads_date;
      if (summary.html_game && !result.creative_formats.some(x => x === 'html')) {
        result.creative_formats.push('html');
      }
      if (summary.video && !result.creative_formats.some(x => x === 'video')) {
        result.creative_formats.push('video');
      }
    });
  }

  return result;
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

export function formatCategorySdksTree (sdks) {
  return sdks.filter(x => x.type === 'sdkCategory').map(category => ({
    value: `${category.id}_${category.platform}_${category.name}`,
    label: `${category.name} (${capitalize(category.platform)}) (${category.sdks.length} SDKs)`,
    children: category.sdks.map(x => ({
      value: `${x[0]}_${category.platform}_${x[1]}_${category.id}`,
      label: x[1],
    })),
  }));
}

export function formatCategorySdksValue (sdks) {
  const result = [];
  sdks.filter(x => x.type === 'sdkCategory').forEach((x) => {
    if (x.sdks.length === x.includedSdks.length) {
      result.push(`${x.id}_${x.platform}_${x.name}`);
    } else {
      x.includedSdks.forEach((y) => {
        result.push(`${y[0]}_${x.platform}_${y[1]}_${x.id}`);
      });
    }
  });

  return result;
}

export function updateCategorySdks (sdks, values) {
  const newSdks = sdks.slice(0);
  newSdks.forEach((x) => {
    if (x.type === 'sdkCategory') {
      x.includedSdks = [];
    }
  });

  values.forEach((val) => {
    const [id, platform, name, parentId] = val.split('_');
    if (!parentId) {
      const idx = newSdks.findIndex(x => x.platform === platform && x.id === parseInt(id, 10) && x.type === 'sdkCategory');
      newSdks[idx].includedSdks = newSdks[idx].sdks;
    } else {
      const idx = newSdks.findIndex(x => x.platform === platform && x.id === parseInt(parentId, 10) && x.type === 'sdkCategory');
      newSdks[idx].includedSdks.push([parseInt(id, 10), name]);
    }
  });

  return newSdks;
}

export function generateQueryDateRange (label, dateRange, dates) {
  if (dateRange === 'anytime') {
    return null;
  }

  let result = [label];
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
    case 'before-date':
      result = result.concat([
        null, dates,
      ]);
      break;
    case 'after-date':
      result = result.concat([
        dates, null,
      ]);
      break;
    default:
      break;
  }

  return result;
}
