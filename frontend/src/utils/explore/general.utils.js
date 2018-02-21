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

export const convertToTableSort = sorts => sorts.map(sort => ({
  id: getSortName(sort.field),
  desc: sort.order === 'desc',
}));

export const convertToQuerySort = sorts => sorts.map(sort => ({
  field: selectMap[sort.id][0],
  order: sort.desc ? 'desc' : 'asc',
  object: 'app',
}));

export const getSortName = (val) => {
  for (let key in selectMap) {
    if (selectMap[key] && selectMap[key].includes(val)) {
      return key;
    }
  }
};
