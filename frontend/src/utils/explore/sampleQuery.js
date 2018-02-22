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
          "operator": "filter",
          "predicates": [
            // [
            //   "or",
            //   [
            //     "user_base",
            //     "elite"
            //   ]
            // ],
            [
              "platform",
              "ios"
            ],
            [
              "not",
              [
                "taken_down"
              ]
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
        },
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
