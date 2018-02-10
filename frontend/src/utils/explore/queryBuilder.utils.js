import { headerNames } from 'Table/redux/column.models';

export function buildRequest (form, columns) {
  const result = {};
  result.query = buildQuery(form.filters);
  result.select = buildSelect(form, columns);
  return result;
}

function buildQuery (filters) {
  const params = {};
  return {
    filters: params,
  };
}

const columnKeys = {
  last_updated: headerNames.LAST_UPDATED,
  mobile_priority: headerNames.MOBILE_PRIORITY,
  platform: headerNames.PLATFORM,
  publisher_id: headerNames.PUBLISHER,
  publisher_name: headerNames.PUBLISHER,
};

function buildSelect (form, columns) {
  const fields = {
    id: true,
    name: true,
    current_version: true,
  };

  for (let key in columnKeys) {
    if (Object.prototype.hasOwnProperty.call(columnKeys, key)) {
      if (columns[columnKeys[key]]) {
        fields[key] = true;
      }
    }
  }

  const result = { 'fields': {} };
  const { resultType } = form;
  result.fields[resultType] = fields;
  result.object = resultType;
  return result;
}
