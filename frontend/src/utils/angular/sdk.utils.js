import { capitalize } from 'utils/format.utils';

export const sdkQuery = (id, platform, name, icon, facebookOnly) => ({
  "page_settings": {
    "page_size": 100
  },
  "sort": {
    "fields": [
      {
        "field": "current_version_release_date",
        "object": "app",
        "order": "desc"
      },
      {
        "field": "id",
        "object": "app",
        "order": "asc"
      },
      {
        "field": "platform",
        "object": "app",
        "order": "asc"
      }
    ]
  },
  "query": {
    "filter": {
      "operator": "intersect",
      "inputs": [
        {
          "operator": "filter",
          "predicates": [
            [
              "not",
              [
                "taken_down"
              ]
            ]
          ],
          "object": "app"
        },
        {
          "operator": "union",
          "inputs": [
            {
              "operator": "union",
              "inputs": [
                {
                  "operator": "intersect",
                  "inputs": [
                    {
                      "object": "sdk_event",
                      "operator": "filter",
                      "predicates": [
                        [
                          "type",
                          "install"
                        ],
                        [
                          "sdk_id",
                          id
                        ],
                        [
                          "platform",
                          platform
                        ]
                      ]
                    },
                    {
                      "object": "app",
                      "operator": "filter",
                      "predicates": [
                        [
                          "platform",
                          platform
                        ]
                      ]
                    },
                    {
                      "object": "sdk",
                      "operator": "filter",
                      "predicates": [
                        [
                          "installed"
                        ],
                        [
                          "id",
                          id
                        ],
                        [
                          "platform",
                          platform
                        ]
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  },
  "select": {
    "fields": {
      "app": {
        "name": true,
        "id": true,
        "current_version": true,
        "icon_url": true,
        "taken_down": true,
        "app_identifier": true,
        "first_scanned_date": true,
        "last_scanned_date": true,
        "price_category": true,
        "original_release_date": true,
        "in_app_purchases": true,
        "publisher": true,
        "platform": true,
        "mobile_priority": true,
        "ad_summaries": facebookOnly ? ['facebook'] : true,
        "sdk_activity": true,
        "user_base": true,
        "international_user_bases": true,
        "categories": true,
        "permissions": true,
        "downloads": true,
        "rankings": {
          "countries": [
            "US",
            "FR",
            "CA",
            "CN",
            "BR",
            "AU",
            "UK",
            "SP",
            "IT",
            "DE",
            "SE",
            "RU",
            "KR",
            "JP",
            "CH",
            "SG",
            "NL",
            "AR"
          ],
          "ranking_types": [
            "free"
          ]
        },
        "newcomers": {
          "countries": [
            "US",
            "FR",
            "CA",
            "CN",
            "BR",
            "AU",
            "UK",
            "SP",
            "IT",
            "DE",
            "SE",
            "RU",
            "KR",
            "JP",
            "CH",
            "SG",
            "NL",
            "AR"
          ],
          "ranking_types": [
            "free"
          ],
          "created_at": [
            "-",
            [
              "utcnow"
            ],
            [
              "timedelta",
              {
                "days": 14
              }
            ]
          ]
        },
        "all_version_rating": true,
        "all_version_ratings_count": true,
        "current_version_release_date": true
      }
    },
    "object": "app"
  },
  "formState": JSON.stringify({
    "resultType": "app",
    "platform": "all",
    "includeTakenDown": false,
    "filters": {
      "sdks": {
        "filters": [
          {
            "dateRange": "anytime",
            "dates": [],
            "eventType": "install",
            "operator": "any",
            "sdks": [{
              "id": id,
              "name": name,
              "favicon": icon,
              "platform": platform,
              "type": "sdk",
              "key": `${id}_${platform}`,
              "label": `${name} (${capitalize(platform)})`
            }],
            "installState": "is-installed",
            "panelKey": "1",
            "displayText": `${name} (${capitalize(platform)}) Installed Anytime and Currently Installed`
          }],
          "operator": "or"
        }
      },
      "version": "1.3.2"
    })
});
