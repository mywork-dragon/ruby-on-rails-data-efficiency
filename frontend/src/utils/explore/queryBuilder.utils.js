import { headerNames } from 'Table/redux/column.models';

/* eslint-disable */
export const sampleQuery = {
  "sort": {
    "fields": [
      {
        "field": "name",
        "object": "app",
        "order": "asc",
      },
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
    ],
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
              "or",
              [
                "mobile_priority",
                "high"
              ],
              [
                "mobile_priority",
                "medium"
              ]
            ]
          ],
          "object": "app"
        }
      ]
    }
  },
  "page_settings": {
    "page_size": 20,
    "page": 1,
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

// map between frontend display fields and backend field
// place sort field at beginning of the list
const selectMap = {
  [headerNames.APP]: ['name', 'id', 'current_version', 'icon_url', 'taken_down', 'app_identifier', 'first_scanned_date'],
  [headerNames.COUNTRIES_AVAILABLE_IN]: ['countries_available_in'],
  [headerNames.LAST_UPDATED]: ['last_updated'],
  [headerNames.MOBILE_PRIORITY]: ['mobile_priority'],
  [headerNames.PLATFORM]: ['platform'],
  [headerNames.PUBLISHER]: ['publisher_name', 'publisher_id', 'seller_url'],
  // [headerNames.RATINGS]: ['all_version_rating', 'all_version_ratings_count'],
  [headerNames.USER_BASE]: ['user_base'],
};

export function buildExploreRequest (form, columns, pageSettings, sort) {
  const result = {};
  result.page_settings = buildPageSettings(pageSettings);
  result.sort = buildSortSettings(sort);
  result.query = buildQuery(form.filters);
  result.select = buildSelect(form.resultType, columns);
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

export function buildQuery (filters) {
  const params = sampleQuery.query.filter;
  return {
    filter: params,
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
