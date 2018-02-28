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
  result.sort = convertToTableSort(fields.slice(0, fields.length - 2));
  result.resultType = resultType;

  return result;
}

function addItemType (app) {
  return {
    ...app,
    type: app.platform === 'ios' ? 'IosApp' : 'AndroidApp',
  };
}

export const convertToTableSort = (sorts) => {
  const tableSorts = [];
  sorts.forEach((sort) => {
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

export const convertToQuerySort = sorts => sorts.map(sort => ({
  field: selectMap[sort.id][0],
  order: sort.desc ? 'desc' : 'asc',
  object: 'app',
}));

export const getSortName = (val) => {
  for (let key in selectMap) {
    const fields = selectMap[key];
    if (fields && fields.includes(val) && fields[0] === val) {
      return key;
    }
  }

  return null;
};

export function formatTableData(columns, pageSize, sort) {
  const result = {};
  result.sort = sort;
  result.pageSize = pageSize;
  result.pageNum = 0;
  result.results = [];
  result.resultsCount = 0;
  result.columns = columns;

  return result;
}

export function panelFilterCount(filters, panelKey) {
  if (panelKey === '1') {
    return filters.filter(x => x.sdks.length > 0).length;
  }

  return Object.values(filters).filter(x => x.panelKey === panelKey).length;
}

export function hasFilters(filters) {
  const keys = Object.keys(filters);
  const sdks = filters.sdks;
  return keys.length > 1 || sdks.filters.some(x => x.sdks.length > 0);
}
