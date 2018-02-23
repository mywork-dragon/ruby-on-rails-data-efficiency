import { selectMap } from './models.utils';
import { convertToQuerySort } from './general.utils';
import { buildFilter } from './filterBuilder.utils';

export function buildExploreRequest (form, columns, pageSettings, sort) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort);
  result.query = buildFilter(form);
  result.select = buildSelect(form.resultType, columns);
  result.formState = JSON.stringify(form);
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

export function buildSelect (resultType, columns) {
  const fields = {};
  const columnNames = Object.keys(columns);

  columnNames.forEach((column) => {
    if (selectMap[column]) {
      selectMap[column].forEach((field) => { fields[field] = true; });
    }
  });

  const result = { fields: {} };
  // result.fields[resultType] = fields;
  // result.object = resultType;
  result.fields.app = fields; // TODO: remove hardcoded app value
  result.object = 'app';
  return result;
}
