import _ from 'lodash';
import { selectMap, sortMap } from './models.utils';
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
  field: sortMap[sort.id].field,
  order: sort.desc ? 'desc' : 'asc',
  object: sortMap[sort.id].object,
}));

export function buildSelect (resultType, columns, accountNetworks) {
  const fields = [];
  const columnNames = Object.keys(columns);

  columnNames.forEach((column) => {
    if (selectMap[column]) {
      selectMap[column].forEach(field => fields.push(field));
    }
  });

  const accessibleNetworks = Object.values(accountNetworks).filter(x => x.can_access);
  const facebookOnly = accessibleNetworks.length === 1 && accessibleNetworks[0].id === 'facebook';

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
