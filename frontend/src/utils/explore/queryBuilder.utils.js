import { $localStorage } from 'utils/localStorage.utils';
import { buildSelect, csvSelect } from './selectBuilder.utils';
import { buildSortSettings } from './sortBuilder.utils';
import { buildFilter } from './filterBuilder.utils';
import { cleanState } from './general.utils';

export function buildExploreRequest (form, columns, pageSettings, sort, accountNetworks) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort, form);
  result.query = buildFilter(form);
  result.select = buildSelect(form, columns, accountNetworks);
  result.formState = JSON.stringify(cleanState(form));
  return result;
}

export function buildCsvRequest (query, facebookOnly, form) {
  const result = {
    ...query,
  };
  result.page_settings = { page_size: 20000 };
  result.select = csvSelect(facebookOnly, query.select.object, form);
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
