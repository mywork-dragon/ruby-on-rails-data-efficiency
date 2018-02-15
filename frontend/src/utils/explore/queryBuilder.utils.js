import { headerNames } from 'Table/redux/column.models';

const columnKeys = {
  [headerNames.APP]: ['id', 'name', 'current_version'], // TODO: add icon_url, app_identifier, taken_down, first_scanned_date
  [headerNames.COUNTRIES_AVAILABLE_IN]: ['countries_available_in'],
  [headerNames.LAST_UPDATED]: ['last_updated'],
  [headerNames.MOBILE_PRIORITY]: ['mobile_priority'],
  [headerNames.PLATFORM]: ['platform'],
  [headerNames.PUBLISHER]: ['publisher_id', 'publisher_name'], // TODO: add seller_url
  // [headerNames.RATINGS]: ['all_version_rating', 'all_version_ratings_count'],
  // [headerNames.USER_BASE]: ['user_base'],
};

/* eslint-disable */
export const sampleQuery = {
  "sort": {
    "fields": [
      {
        "field": "id",
        "object": "app"
      }
    ],
    "order": "asc"
  },
  "query": {
    "filter": {
      "operator": "intersect",
      "inputs": [
        {
          "operator": "union",
          "inputs": [
            {
              "operator": "filter",
              "predicates": [
                [
                  "type",
                  "install"
                ],
                [
                  "sdk_id",
                  200
                ]
              ],
              "object": "sdk_event"
            },
            {
              "operator": "filter",
              "predicates": [
                [
                  "type",
                  "install"
                ],
                [
                  "sdk_id",
                  114
                ]
              ],
              "object": "sdk_event"
            }
          ]
        },
        {
          "operator": "filter",
          "predicates": [
            [
              "or",
              [
                "user_base",
                "elite"
              ]
            ],
            [
              "platform",
              "ios"
            ],
            [
              "mobile_priority",
              "high"
            ]
          ],
          "object": "app"
        }
      ]
    }
  },
  "page_settings": {
    "page_size": 201
  },
  "select": {
    "fields": {
      "app": {
        "id": true,
        "name": true
      }
    },
    "object": "app"
  }
}
/* eslint-enable */

export function buildExploreRequest (form, columns, pageSettings, sort) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.query = buildQuery(form.filters);
  result.select = buildSelect(form.resultType, columns);
  return result;
}

export function buildPageSettings ({ pageSize, pageNum }) {
  return {
    page_size: pageSize,
    page: pageNum + 1,
  };
}

export function buildQuery (filters) {
  const params = sampleQuery.query.filters;
  return {
    filters: params,
  };
}

export function buildSelect (resultType, columns) {
  const fields = {};
  const columnNames = Object.keys(columns);

  columnNames.forEach((column) => {
    if (columnKeys[column]) {
      columnKeys[column].forEach((field) => { fields[field] = true; });
    }
  });

  const result = { fields: {} };
  // result.fields[resultType] = fields;
  // result.object = resultType;
  result.fields.app = fields; // TODO: remove hardcoded app value
  result.object = 'app';
  return result;
}
