import _ from 'lodash';
import { getMaxDate, getMinDate, capitalize } from 'utils/format.utils';
import { $localStorage } from 'utils/localStorage.utils';
import { sdkFilterModel } from 'containers/ExplorePage/redux/searchForm.reducers';
import { sortMap } from './models.utils';

export function formatResults (data, resultType, params, count) {
  const result = {};

  result.results = Object.values(data.pages)[0].map(x => (resultType === 'app' ? formatApp(x) : formatPublisher(x)));
  result.pageNum = parseInt(Object.keys(data.pages)[0], 10);
  if (params) {
    const {
      page_settings: { page_size: pageSize },
      sort: { fields },
    } = params;

    result.pageSize = pageSize;
    result.sort = convertToTableSort(fields, resultType);
    result.resultType = resultType;
  }
  if (count) result.resultsCount = count;

  return result;
}

function formatApp (app) {
  return {
    ...app,
    ...(addItemType(app)),
    categories: formatCategories(app.categories),
    ...formatAdintelInfo(app),
    userBases: app.international_user_bases,
    rating: app.all_version_rating,
    ratingsCount: app.all_version_ratings_count,
    rankings: app.rankings || {},
    resultType: 'app',
  };
}

function formatPublisher (publisher) {
  return {
    ...publisher,
    appStoreId: publisher.publisher_identifier,
    lastUpdated: publisher.last_app_update_date,
    first_seen_ads_date: publisher.first_seen_ads,
    last_seen_ads_date: publisher.last_seen_ads,
    rating: publisher.average_ratings,
    ratingsCount: publisher.total_ratings,
    downloads: publisher.total_downloads,
    ad_networks: publisher.ad_networks.map(x => ({ id: x })),
    fortuneRank: getFortuneRank(publisher.companies),
    locations: getLocations(publisher.companies),
    resultType: 'publisher',
  };
}

function formatCategories (categories) {
  if (!categories) {
    return [];
  }

  return categories.map(x => x.name);
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

function getFortuneRank (companies) {
  const ranks = _.compact(companies.map(x => x.fortune_1000_rank));
  return ranks.length ? Math.min(...ranks) : 'No rank';
}

function getLocations (companies) {
  const result = [];

  companies.forEach((x) => {
    const data = {
      city: x.city,
      country: x.country,
      country_code: x.country_code,
      // postal_code: x.postal_code,
      state: x.state,
      state_code: x.state_code,
      // street_name: x.street_name,
      // street_number: x.street_number,
    };

    Object.keys(data).forEach((y) => {
      if (!data[y]) delete data[y];
    });

    if (Object.entries(data).length && (result.length === 0 || companies.every(y => noMatch(data, y)))) result.push(data);
  });

  return result;
}

const noMatch = (location1, location2) => location1.city !== location2.city || location1.state_code !== location2.state_code || location1.country_code !== location2.country_code;

export const convertToTableSort = (sorts, resultType) => {
  const tableSorts = [];
  if (resultType === 'app') {
    sorts = sorts.slice(0, sorts.length - 2);
  }
  sorts.forEach((sort) => {
    const sortName = getSortName(sort, resultType);
    if (sortName && sortName !== 'Platform') {
      tableSorts.push({
        id: sortName,
        desc: sort.order === 'desc',
      });
    }
  });

  return tableSorts;
};

export const getSortName = (sort, resultType) => {
  const map = sortMap(resultType);
  const { field, object } = sort;
  for (const key in map) {
    if (map[key]) {
      const mappedSort = map[key];
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

export function formatCategorySdksTree (iosSdkCategories, androidSdkCategories, platform) {
  const treeData = [];

  if (platform !== 'android') {
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
  }

  if (platform !== 'ios') {
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
    case 'day':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { days: 1 }]],
        ['utcnow'],
      ]);
      break;
    case 'two-day':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { days: 2 }]],
        ['utcnow'],
      ]);
      break;
    case 'three-day':
      result = result.concat([
        ['-', ['utcnow'], ['timedelta', { days: 3 }]],
        ['utcnow'],
      ]);
      break;
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

export function isCurrentQuery(query) {
  const location = window.location.href;
  const currentQuery = location.substr(location.lastIndexOf('/') + 1);
  return currentQuery !== 'v2' && query === currentQuery;
}

export function setExploreColumns (type, columns) {
  $localStorage.set(`explore${capitalize(type)}Columns`, columns);
}

export function getExploreColumns (type) {
  return $localStorage.get(`explore${capitalize(type)}Columns`);
}

export function filterRankings (charts, currentCountries, field) {
  let sorted = charts;
  if (!currentCountries) {
    const defaultCountries = ['AU', 'CA', 'GB', 'FR', 'CN', 'US'];
    sorted = _.sortBy(sorted, x => defaultCountries.indexOf(x.country)).reverse().slice(0, 16);
  }

  if (field === 'rank') return _.sortBy(sorted, x => x[field]);
  if (field === 'date') return _.sortBy(sorted, x => x[field]).reverse();

  return _.sortBy(sorted, x => Math.abs(x[field])).reverse();
}
