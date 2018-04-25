import _ from 'lodash';
import { $localStorage } from 'utils/localStorage.utils';
import { selectMap, sortMap, csvSelect } from './models.utils';
import { buildFilter } from './filterBuilder.utils';
import { cleanState } from './general.utils';


export function buildExploreRequest (form, columns, pageSettings, sort, accountNetworks) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort, form.resultType);
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
  result.select = csvSelect(facebookOnly, query.select.object);
  return result;
}


export function buildCsvLink (csvQueryId, permissions) {
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
          const max_page = Math.floor(page_depth / page_size);
          pages = "0-" + max_page.toString();
        }
      }
    }

    return `${window.MQUERY_SERVICE}/query/${csvQueryId}/query_result/pages/${pages}?stream=true&formatter=csv&JWT=${$localStorage.get('queryToken')}`;
  }
  return null;
}

export function buildPageSettings ({ pageSize, pageNum }) {
  return {
    page_size: pageSize,
    page: pageNum,
  };
}

export function buildSortSettings (sorts, resultType) {
  const result = { fields: [] };
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

  const formattedSorts = convertToQuerySort(sorts, resultType);

  if (!formattedSorts.length) {
    if (resultType === 'app') {
      result.fields = [{ field: 'current_version_release_date', object: 'app', order: 'desc' }].concat(defaultSorts);
    } else if (resultType === 'publisher') {
      result.fields = [
        {
          field: 'current_version_release_date',
          object: 'app',
          order: 'desc',
          function: 'max',
        },
      ];
    }
  } else if (resultType === 'app') {
    result.fields = formattedSorts.concat(defaultSorts);
  } else if (resultType === 'publisher') {
    result.fields = formattedSorts;
  }

  return result;
}

export const convertToQuerySort = (sorts, resultType) => _.compact(sorts.map((sort) => {
  const map = sortMap(resultType);

  if (map[sort.id]) {
    return {
      ...sortMap(resultType)[sort.id],
      order: sort.desc ? 'desc' : 'asc',
    };
  }
  return null;
}));

export function buildSelect (resultType, columns, accountNetworks) {
  const fields = [];
  const columnNames = Object.keys(columns);

  const selects = selectMap(resultType);

  columnNames.forEach((column) => {
    if (selects[column]) {
      selects[column].forEach(field => fields.push(field));
    }
  });

  const facebookOnly = accountNetworks.length === 1 && accountNetworks[0].id === 'facebook';

  const mappedFields = {};

  _.uniq(fields).forEach((field) => {
    if (['ad_summaries', 'ad_networks', 'first_seen_ads', 'last_seen_ads'].includes(field) && facebookOnly) {
      mappedFields[field] = ['facebook'];
    } else {
      mappedFields[field] = true;
    }
  });

  const result = {
    fields: {
      [resultType]: mappedFields,
    },
    object: resultType,
  };

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
