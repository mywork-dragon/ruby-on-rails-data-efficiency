import _ from 'lodash';
import { $localStorage } from 'utils/localStorage.utils';
import { headerNames } from 'Table/redux/column.models';
import { selectMap, sortMap, csvSelect } from './models.utils';
import { buildFilter } from './filterBuilder.utils';
import { cleanState, generateQueryDateRange } from './general.utils';

export function buildExploreRequest (form, columns, pageSettings, sort, accountNetworks) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort, form);
  result.query = buildFilter(form);
  result.select = buildSelect(form, columns, accountNetworks);
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

export function buildSortSettings (sorts, form) {
  const result = { fields: [] };
  const { resultType } = form;
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

  const formattedSorts = convertToQuerySort(sorts, form);

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

export const convertToQuerySort = (sorts, form) => _.compact(sorts.map((sort) => {
  const map = sortMap(form);

  if (map[sort.id]) {
    const result = {
      ...sortMap(form)[sort.id],
      order: sort.desc ? 'desc' : 'asc',
    };

    if (sort.id === headerNames.RANK) {
      result.order = sort.desc ? 'asc' : 'desc';
    } else if ([headerNames.MONTHLY_CHANGE, headerNames.WEEKLY_CHANGE, headerNames.ENTERED_CHART].includes(sort.id)) {
      result.function = sort.desc ? 'max' : 'min';
    }

    return result;
  }
  return null;
}));

export function buildSelect ({ resultType, filters: { rankings }, platform }, columns, accountNetworks) {
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
    } else if (field === 'rankings') {
      const rankingsFilterValues = {};
      const newcomersFilterValues = {};
      if (rankings) {
        const {
          countries,
          iosCategories = [],
          androidCategories = [],
          charts,
          eventType,
          values,
          operator,
          dateRange,
          trendOperator,
        } = rankings.value;
        if (countries) rankingsFilterValues.countries = countries.split(',');
        if (iosCategories.length || androidCategories.length) rankingsFilterValues.categories = iosCategories.concat(androidCategories).map(x => x.value);
        if (charts) rankingsFilterValues.ranking_types = charts.split(',');
        if (platform !== 'all') rankingsFilterValues.platform = [platform];
        if (eventType.value === 'rank') {
          if (operator === 'less-than') values[0] = null;
          if (operator === 'between') {
            rankingsFilterValues.rank = values;
          } else {
            rankingsFilterValues.rank = values.slice().reverse();
          }
        } else if (eventType.value === 'trend') {
          let vals = values.slice();
          if (trendOperator === 'down') {
            vals = vals.reverse();
            vals = vals.map((x) => {
              if (typeof x === 'number' && x > 0) {
                return -x;
              } else if (operator === 'less-than') {
                return 0;
              }
              return x;
            });
          }
          if (dateRange.value === 'week') {
            rankingsFilterValues.weekly_change = vals;
          } else if (dateRange.value === 'month') {
            rankingsFilterValues.monthly_change = vals;
          }
        } else if (eventType.value === 'newcomer') {
          const date = generateQueryDateRange('created_at', dateRange.value);
          newcomersFilterValues.created_at = date[1];
        }
      } else {
        rankingsFilterValues.countries = ['US', 'FR', 'CA', 'CN', 'BR', 'AU', 'UK', 'SP', 'IT', 'DE', 'SE', 'RU', 'KR', 'JP', 'CH', 'SG', 'NL'];
        rankingsFilterValues.ranking_types = ['free'];
        newcomersFilterValues.created_at = generateQueryDateRange('created_at', 'two-week')[1];
      }
      mappedFields.rankings = rankingsFilterValues;
      mappedFields.newcomers = { ...rankingsFilterValues, ...newcomersFilterValues };
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
