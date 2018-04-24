import _ from 'lodash';
import { $localStorage } from 'utils/localStorage.utils';
import { selectMap, sortMap, csvSelect } from './models.utils';
import { buildFilter } from './filterBuilder.utils';
import { cleanState } from './general.utils';


export function buildExploreRequest (form, columns, pageSettings, sort, accountNetworks) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort);
  result.query = buildFilter(form);
  result.select = buildSelect(form.resultType, columns, accountNetworks);
  result.formState = JSON.stringify(cleanState(form));
  return result;
}

export function buildCsvRequest (query, facebookOnly) {
  const result = {
    ...query,
  };
  result.page_settings = { page_size: 20000 };
  result.select = csvSelect(facebookOnly);
  return result;
}


export function buildCsvLink (csvQueryId, csvNumPages, permissions) {
  var pages = '0';
  const mquery_prefix = 'mightyquery:page_depth_level_';
  const page_size = 20000;

  if (csvQueryId) {
    if (permissions.features) {
      var page_depths = Object.entries(permissions.features).filter(
          (x) => (x[1] && x[0].startsWith(mquery_prefix))).map((x) => (x[0].replace(mquery_prefix, '')));

      if (page_depths.includes('all')) {
        pages = '*';
      } else {
        page_depths = page_depths.filter((x) => (!isNaN(x))).map(parseInt);
        if (page_depths.length > 0) {
          const page_depth = Math.max(...page_depths);
          const max_page = Math.min(Math.floor(page_depth / page_size), csvNumPages);
          pages = "0-" + max_page.toString();
        }
      }
    }

    return `${window.MQUERY_SERVICE}/query_result/${csvQueryId}/pages/${pages}?stream=true&formatter=csv&JWT=${$localStorage.get('queryToken')}`;
  }
  return null;
}

export function buildPageSettings ({ pageSize, pageNum }) {
  return {
    page_size: pageSize,
    page: pageNum,
  };
}

export function buildSortSettings (sorts) {
  const defaultSorts = [
    {
      field: 'id',
      object: 'app',
      order: 'asc',
    },
    {
      field: 'platform',
      object: 'app',
      order: 'asc',
    },
  ];
  const formattedSorts = convertToQuerySort(sorts);
  return {
    fields: formattedSorts.concat(defaultSorts),
  };
}

export const convertToQuerySort = sorts => sorts.map(sort => ({
  ...sortMap[sort.id],
  order: sort.desc ? 'desc' : 'asc',
}));

export function buildSelect (resultType, columns, accountNetworks) {
  const fields = [];
  const columnNames = Object.keys(columns);

  columnNames.forEach((column) => {
    if (selectMap[column]) {
      selectMap[column].forEach(field => fields.push(field));
    }
  });

  const facebookOnly = accountNetworks.length === 1 && accountNetworks[0].id === 'facebook';

  const mappedFields = {};

  _.uniq(fields).forEach((field) => {
    if (field === 'ad_summaries' && facebookOnly) {
      mappedFields[field] = ['facebook'];
    } else {
      mappedFields[field] = true;
    }
  });

  const result = { fields: {} };
  // result.fields[resultType] = fields;
  // result.object = resultType;
  result.fields.app = mappedFields; // TODO: remove hardcoded app value
  result.object = 'app';
  return result;
}

export function requirePlatformFilter (filter, platform) {
  return {
    operator: 'intersect',
    inputs: [
      filter,
      {
        object: 'app',
        operator: 'filter',
        predicates: [
          ['platform', platform],
        ],
      },
    ],
  };
}
