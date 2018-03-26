import _ from 'lodash';
import { getMaxDate, getMinDate } from 'utils/format.utils';
import { $localStorage } from 'utils/localStorage.utils';
import { sdkFilterModel } from 'containers/ExplorePage/redux/searchForm.reducers';
import { sortMap } from './models.utils';

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
  } else if (categories.length === 0) {
    return categories;
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
    adSpend: ad_summaries !== null && ad_summaries.length > 0,
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
    const sortName = getSortName(sort);
    if (sortName && sortName !== 'Platform') {
      tableSorts.push({
        id: sortName,
        desc: sort.order === 'desc',
      });
    }
  });

  return tableSorts;
};

export const getSortName = (sort) => {
  const { field, object } = sort;
  for (const key in sortMap) {
    if (sortMap[key]) {
      const mappedSort = sortMap[key];
      if (mappedSort && mappedSort.field === field && mappedSort.object === object) {
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
    if (sdkFilters.length === 0) {
      sdkFilters.push(sdkFilterModel);
    }
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
  }

  if (cleanedState.filters.adNetworks && cleanedState.filters.adNetworks.value.adNetworks.length === 0) {
    delete cleanedState.filters.adNetworks;
  }


  return cleanedState;
}

export function formatCategorySdksTree (iosSdkCategories, androidSdkCategories) {
  const treeData = [];

  for (const key in iosSdkCategories) {
    if (iosSdkCategories[key]) {
      treeData.push({
        label: `${key} (iOS)`,
        value: `${key}_ios`,
        key: `${key}_ios`,
        children: iosSdkCategories[key].sdks.map(x => ({
          label: `${x.name} (iOS)`,
          value: `${x.id}_ios_${x.name}_${key}`,
          key: `${x.id}_ios_${x.name}_${key}`,
        })),
      });
    }
  }

  for (const key in androidSdkCategories) {
    if (androidSdkCategories[key]) {
      treeData.push({
        label: `${key} (Android)`,
        value: `${key}_android`,
        key: `${key}_android`,
        children: androidSdkCategories[key].sdks.map(x => ({
          label: `${x.name} (Android)`,
          value: `${x.id}_android_${x.name}_${key}`,
          key: `${x.id}_android_${x.name}_${key}`,
        })),
      });
    }
  }

  return treeData;
}

export function formatCategorySdksValue (sdks) {
  const result = [];
  sdks.filter(x => x.sdks).forEach((x) => {
    if (x.sdks.length === x.includedSdks.length) {
      result.push(`${x.name}_${x.platform}`);
    } else {
      x.includedSdks.forEach((y) => {
        result.push(`${y.id}_${x.platform}_${y.name}_${x.name}`);
      });
    }
  });

  return result;
}

export function updateCategorySdks (sdks, values, iosSdkCategories, androidSdkCategories) {
  const newSdks = sdks.slice(0).filter(x => !x.sdks); // remove all sdk categories

  values.forEach((value) => {
    const [id, platform, name, parentId] = value.split('_');
    const platformCategories = platform === 'ios' ? iosSdkCategories : androidSdkCategories;
    if (!parentId) {
      const category = {
        ...platformCategories[id],
        id,
        platform,
      };
      category.includedSdks = category.sdks;
      newSdks.push(category);
    } else {
      const idx = newSdks.findIndex(x => x.platform === platform && x.id === parentId && x.sdks);
      if (idx === -1) {
        const category = {
          ...platformCategories[parentId],
          id: parentId,
          platform,
        };
        category.includedSdks = [{ id: parseInt(id, 10), name }];
        newSdks.push(category);
      } else {
        newSdks[idx].includedSdks.push({ id: parseInt(id, 10), name });
      }

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

export function setExploreColumns (columns) {
  $localStorage.set('exploreTableColumns', columns);
}

export function getExploreColumns () {
  return $localStorage.get('exploreTableColumns');
}
