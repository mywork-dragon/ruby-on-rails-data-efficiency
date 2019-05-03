---
title: MightySignal API Docs

language_tabs:
  - shell

includes:
  - errors
  - changelog

search: true
---

# Overview

Welcome to the documentation for the MightySignal API. For access, please [contact us](mailto:support@mightysignal.com) to get your API token.

The API is accessed from `https://api.mightysignal.com`. All data is returned as JSON.

# Authentication

> To authenticate:

```bash
# You should pass the header with each request
curl "https://api.mightysignal.com/<your-endpoint-of-interest>"
  -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

> Make sure to replace `<your-api-token>` with your API token.

Authentication is done via HTTP Headers on each request with your MightySignal API token:

`MIGHTYSIGNAL-TOKEN: <your-api-token>`

<aside class="notice">
You must replace <code>&ltyour-api-token&gt</code> with your personal API token.
</aside>

**All API requests must be made over HTTPS.** Calls made over plain HTTP will fail with a redirect.

# iOS Apps

## Get information about a specific app

> Example: Retrieve the latest information about Airbnb's iOS app

```bash
curl "https://api.mightysignal.com/ios/app/401626263"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
   "price" : 0,
   "support_url" : "https://airbnb.com/help",
   "id" : 258389,
   "app_store_id" : 401626263,
   "first_seen_ads_date" : "2016-06-04T07:07:27.000Z",
   "platform" : "ios",
   "current_version_ratings_count" : 4765,
   "categories" : [
      {
         "platform" : "ios",
         "type" : "primary",
         "id" : 6003,
         "name" : "Travel"
      },
      {
         "platform" : "ios",
         "id" : 6012,
         "type" : "secondary",
         "name" : "Lifestyle"
      }
   ],
   "installed_sdks" : [
      {
         "id" : 3,
         "name" : "1PasswordExtension",
         "categories" : [
            "Authentication"
         ],
         "first_seen_date" : "2015-12-10T18:29:06.000-08:00",
         "last_seen_date" : "2018-05-30T17:44:31.000-07:00"
      },
    ...
   ],
   "bundle_identifier" : "com.airbnb.app",
   "current_version" : "18.24",
   "seller" : "Airbnb, Inc.",
   "description" : "Unforgettable travel experiences start with Airbnb. Find travel adventures and new places to go faraway or near to you, and access vacation home rentals, new experiences, and places to visit all around the world. Book everything for your trip, or start earning money as a host. \n\nBOOK TRAVEL EXPERIENCES\nGo on local experiences led by native experts, whether it’s for multiple days or just an afternoon. Explore Seoul's underground music scene, hunt for truffles in a Tuscan forest, or give back to the community with a social impact experience.\n\nBOOK VACATION HOMES\nChoose from over 4 million vacation home rentals across 191+ countries. Search by price, neighborhood, amenities, and more.\n\nPOPULAR DESTINATIONS\nExperience the beautiful sights & find local guides for the perfect vacation:\n• Rio – Explore the birth place of Samba or Hand Glide over the sights\n• Paris – Find your fill in some of the best culinary tours and museums\n• Barcelona – Discover the cities beauty with guided walking tours\n\nFor travelers: \n• Book vacation home rentals and travel experiences for your next solo journey, family vacation, or business trip\n• Search for last minute travel accommodations or long term rentals\n• Save your favorite rental homes, experiences, and places—and invite friends and family to plan the trip with you\n• Add experiences and events to your itinerary\n• Message your host and get directions to your home\n\nFor hosts:\n• Share your extra space or lead experiences that showcase what makes your city great\n• Update your listing and calendar availability\n• Share what’s special about your neighborhood with a host guidebook\n• Message guests and manage their reservations",
   "taken_down" : false,
   "name" : "Airbnb",
   "first_scanned_date" : "2015-12-11T02:29:06.000Z",
   "has_ad_spend" : true,
   "current_version_rating" : "5.0",
   "original_release_date" : "2010-11-10",
   "last_seen_ads_date" : "2018-02-08T16:52:49.000Z",
   "publisher" : {
      "platform" : "ios",
      "id" : 110570,
      "app_store_id" : 401626266,
      "name" : "Airbnb, Inc."
   },
   "last_updated" : "2018-06-13",
   "user_base" : "elite",
   "all_version_rating" : "4.5",
   "has_in_app_purchases" : false,
   "mobile_priority" : "high",
   "uninstalled_sdks" : [
      {
         "id" : 5,
         "categories" : [
            "Ad Attribution"
         ],
         "name" : "Adjust",
         "first_seen_date" : "2015-12-10T18:29:06.000-08:00",
         "last_seen_date" : "2016-03-22T22:25:04.000-07:00"
      },
    ...
   ],
   "all_version_ratings_count" : 181528,
   "last_scanned_date" : "2018-05-31T00:44:31.000Z"
}
```

### HTTP Request Format

`GET /ios/app/<app_store_id>`

where `<app_store_id>` is the ID from the App Store. For example, Airbnb's App Store ID is `401626263`, which you can find by looking at its iTunes URL: [(https://itunes.apple.com/us/app/airbnb/id401626263)](https://itunes.apple.com/us/app/airbnb/id401626263). If you don't already know the iTunes URL of an app, you can find it on the [app's MightySignal page](http://mightysignal.com/app/app#/app/ios/258389).

### Response

Key | Description
--- | -----------
id | The MightySignal ID of the app
name | Name of the app
mobile_priority | How much the company cares about the app. Currently, the rank is a function of how recently the app has been updated, and whether they advertise on Facebook. `high`: Updated within the past 2 months or advertised on Facebook. `medium`: Updated within last 2-4 months. `low`: Last update more than 4 months ago.
user_base | How large the user base is. Can be `elite`, `moderate`, `strong`, or `weak`.
support_url | The support URL
current_version_rating | Average rating (out of 5) for the current version
current_version_ratings_count | Number of ratings for the current version
all_version_rating | Average rating (out of 5) for all versions
all_version_ratings_count | Number of ratings for all versions
has_ad_spend | We have detected this app advertising on Facebook. Note: If this value is not true, that doesn't mean that it's not advertising; it just means we haven't detected an advertisement.
last_updated | The last date the app was updated
first_seen_ads_date | The date we first saw Facebook ads for this app
last_seen_ads_date | The date we last saw Facebook ads for this app
first_scanned_date | The date we first scanned this app for SDKs
last_scanned_date | The date we last scanned this app for SDKs
has_in_app_purchases | Whether the app has in-app purchases
seller | Seller name
categories.name | The name of the category
catgories.type | The type of the category for this app (`primary` or `secondary`)
original_release_date | Release date of the first version of the app
current_version | The current version of the app
price | The price (in $)
description | App description
installed_sdks.id | MightySignal ID of the installed SDK. It's recommended you store this so you can reference the SDK easily.
installed_sdks.name | Name of the installed SDK
installed_sdks.first_seen_date | The first date the SDK was seen in the app.
installed_sdks.last_seen_date | The last date the SDK was seen in the app
installed_sdks.categories | The categories of this SDK.
uninstalled_sdks.id | The MightySignal ID of the uninstalled SDK. It's recommended you store this so you can reference the SDK easily.
uninstalled_sdks.name | Name of the uninstalled SDK
uninstalled_sdks.first_seen_date | The first date the SDK was seen in the app.
uninstalled_sdks.last_seen_date | The last date the SDK was seen in the app
uninstalled_sdks.categories | The categories of this SDK.
publisher.id | The MightySignal ID of the publisher
publisher.name | Name of the publisher
publisher.platform | `ios`
publisher.app_store_id | The App Store ID of the publisher
platform | `ios`
app_store_id | The App Store ID of the app

## Filter on iOS Apps

Using query parameters, you can do basic filtering to find iOS apps that meet your criteria

> Example: Get all apps published by Uber Technologies, Inc.

```bash
curl "https://api.mightysignal.com/ios/app?publisher_id=200033"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
   "results_count" : 3,
   "total_results_count" : 3,
   "page" : 1,
   "total_page_count" : 1,
   "page_size" : 25,
   "apps" : [
      {
         "original_release_date" : "2010-05-20",
         "has_in_app_purchases" : false,
         "platform" : "ios",
         "rating" : "4.0",
         "has_ad_spend" : true,
         "publisher" : {
            "platform" : "ios",
            "name" : "Uber Technologies, Inc.",
            "id" : 200033
         },
         "mobile_priority" : "high",
         "app_store_id" : 368677368,
         "current_version" : "2.134.3",
         "last_updated" : "2016-05-18",
         "first_seen_ads_date" : "2016-01-15",
         "last_seen_ads_date" : "2016-02-30",
         "first_scanned_date" : "2016-05-15",
         "last_scanned_date" : "2016-07-08",
         "price" : 0,
         "support_url" : "https://support.uber.com/home",
         "seller" : "Uber Technologies, Inc.",
         "current_version_rating" : "3.5",
         "current_version_ratings_count" : 174,
         "all_versions_rating" : "3.5",
         "all_versions_ratings_count" : 8275,
         "user_base" : "elite",
         "categories" : [
            "..."
         ],
         "id" : 596273,
         "name" : "Uber"
      },
      "..."
   ]
}
```

### HTTP Request Format
`GET /ios/app?<key1>=<value1>,<value2>&<key2>=<value1>,<value2>&...`

### Query Parameters
Key | Description
--------- | -----------
publisher_id | **integer** <br>If set, the result will only include apps released by this publisher
installed_sdk_id | **integer** <br>If set, the result will only include apps that have the SDK installed
has_ad_spend | **boolean** <br>If true, the result will only include apps that we know are advertising on Facebook
order_by | **string** <br>Order results by field. Must be one of:<br><code>first_seen_ads_date</code><br><code>last_seen_ads_date</code><br><code>first_scanned_date</code><br><code>last_scanned_date</code><br><code>last_updated</code><br><code>original_release_date</code>.<br>By default, results are in ascending order. Include <code>-</code> in front of the value to order results in descending order e.g. <code>-last_seen_ads_date</code>

You can use the [MightySignal web portal](http://mightysignal.com/app/app) to find the ids for the query parameters.

For example, the `publisher_id` would be `200033` for Uber Technlogies, Inc. since its MightySignal link is [http://mightysignal.com/app/app#/publisher/ios/200033](http://mightysignal.com/app/app#/publisher/ios/200033), and the `installed_sdk_id` for Mixpanel would be `1896` since its MightySignal link is [http://mightysignal.com/app/app#/sdk/ios/1896](http://mightysignal.com/app/app#/sdk/ios/1896).

Alternatively, if you know of an app that meets the criteria (i.e. has a certain SDK or by a certain publisher), use the [simple app route](#filter-on-ios-apps) and pluck the IDs off the response.

<aside class="notice">
You can specify multiple values for a given query parameter, and they will be treated like an OR statement. For example, passing the query string <code>?installed_sdk_id=1,2&publisher_id=10</code> will only return apps by publisher with id 10 that have installed the iOS SDK with id 1 or the iOS SDK with id 2.
</aside>

### Response

Key | Description
--- | -----------
results_count | See [Pagination](#pagination)
total_results_count | See [Pagination](#pagination)
page | See [Pagination](#pagination)
total_page_count | See [Pagination](#pagination)
page_size | See [Pagination](#pagination)
apps | An array of iOS apps. You can look at the response format [here](#get-information-about-a-specific-app)

### Notes

* Your query results will often return a large number of apps and you will be required to page through all the responses. See the [Pagination](#pagination) section for more information.

# Android Apps

## Get information about a specific app


> Example: Retrieve the latest information about Snapchat's Android app

```bash
curl "https://api.mightysignal.com/android/app/com.snapchat.android"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
  "id" : 444,
  "name" : "Snapchat",
  "mobile_priority" : "high",
  "user_base" : "elite",
  "all_version_rating" : "3.9",
  "all_version_ratings_count" : 8308259,
  "downloads_min" : 100000000,
  "downloads_max" : 500000000,
  "last_updated" : "2016-08-30",
  "first_scanned_date" : "2016-05-15",
  "last_scanned_date" : "2016-07-08",
  "seller" : "Snapchat Inc",
  "categories" : [
     {
        "name" : "Social"
     }
  ],
  "current_version" : "9.38.0.0",
  "price" : 0,
  "description" : "...",
  "first_seen_ads_date" : "2016-01-15",
  "last_seen_ads_date" : "2016-02-30",
  "installed_sdks" : [
    {
      "id" : 42,
      "name" : "Flurry",
      "first_seen_date" : "2015-12-16T20:35:21.000Z",
      "last_seen_date" : "2016-05-23T02:41:09.000Z",
      "categories" : ["Analytics"]
    },
    "..."
  ],
  "uninstalled_sdks" : [
    {
      "id" : 1,
      "name" : "Hockey App",
      "first_seen_date" : "2015-12-16T20:35:21.000Z",
      "last_seen_date" : "2015-12-16T20:35:21.000Z",
      "categories" : []
    },
    "..."
  ],
  "publisher" : {
     "id" : 360,
     "name" : "Snapchat Inc",
     "platform" : "android"
  },
  "platform" : "android",
  "google_play_id" : "com.snapchat.android"
}
```

### HTTP Request Format

`GET /android/app/<google_play_id>`

where `<google_play_id>` is the ID from the App Store. For example, Snapchat's App Store ID is `com.snapchat.android`, which you can find by looking at its Google Play URL: [(https://play.google.com/store/apps/details?id=com.snapchat.android)](https://play.google.com/store/apps/details?id=com.snapchat.android). If you don't alreay know the Google Play URL of an app, you can find it on the [app's MightySignal page](https://play.google.com/store/apps/details?id=com.snapchat.android).

### Response

Key | Description
--- | -----------
id | The MightySignal ID of the app
name | Name of the app
mobile_priority | How much the company cares about the app. Currently, the rank is a function of how recently the app has been updated, and whether they advertise on Facebook. `high`: Updated within the past 2 months or advertised on Facebook. `medium`: Updated within last 2-4 months. `low`: Last update more than 4 months ago.
user_base | How large the user base is. Can be `elite`, `moderate`, `strong`, or `weak`.
all_version_rating | Average rating (out of 5) for all versions
all_version_ratings_count | Number of ratings for all versions
downloads_min | The min estimated downloads
downloads_max | The max estimated downloads
last_updated | The last date the app was updated
first_scanned_date | The date we first scanned this app for SDKs
last_scanned_date | The date we last scanned this app for SDKs
seller | Seller name
categories.name | The name of the category
current_version | The current version of the app
price | The price (in $)
description | App description
installed_sdks.id | MightySignal ID of the installed SDK
installed_sdks.name | Name of the installed SDK
installed_sdks.first_seen_date | The first date the SDK was seen in the app. It's recommended you store this so you can reference the SDK easily.
installed_sdks.last_seen_date | The last date the SDK was seen in the app.
installed_sdks.categories | The categories of this SDK.
uninstalled_sdks.id | The MightySignal ID of the uninstalled SDK. It's recommended you store this so you can reference the SDK easily.
uninstalled_sdks.name | Name of the uninstalled SDK
uninstalled_sdks.last_seen_date | The last date the SDK was seen in the app
uninstalled_sdks.first_seen_date | The first date the SDK was seen in the app
uninstalled_sdks.categories | The categories of this SDK.
publisher.id | The MightySignal ID of the publisher
publisher.name | Name of the publisher
publisher.platform | `android`
platform | `android`
google_play_id | The Google Play ID of the app

## Filter on Android Apps

Using query parameters, you can do basic filtering to find Android apps that meet your criteria.

> Example: Get all apps published by Supercell

```bash
curl "https://api.mightysignal.com/android/app?publisher_id=12"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
  "results_count" : 4,
  "total_results_count" : 4,
  "page" : 1,
  "total_page_count" : 1,
  "page_size" : 25,
  "apps" : [
    {
      "rating" : "4.6",
      "price" : 0,
      "platform" : "android",
      "id" : 16,
      "publisher" : {
         "id" : 12,
         "name" : "Supercell",
         "platform" : "android"
      },
      "current_version" : "8.212.12",
      "downloads_min" : 100000000,
      "user_base" : "elite",
      "seller" : "Supercell",
      "mobile_priority" : "high",
      "last_updated" : "2016-04-20",
      "first_scanned_date" : "2016-05-15",
      "last_scanned_date" : "2016-07-08",
      "first_seen_ads_date" : "2016-01-15",
      "last_seen_ads_date" : "2016-02-30",
      "categories" : [
         "..."
      ],
      "downloads_max" : 500000000,
      "all_version_rating" : "4.6",
      "all_version_ratings_count" : 26795286,
      "name" : "Clash of Clans",
      "description" : "...",
      "google_play_id" : "com.supercell.clashofclans"
    },
    "..."
   ]
}
```

### HTTP Request Format
`GET /android/app?<key1>=<value1>,<value2>&<key2>=<value1>,<value2>&...`

### Query Parameters
Key | Default Value | Description
--------- | ------- | -----------
publisher_id | null | If set, the result will only include apps made by this publisher
installed_sdk_id | null | If set, the result will only include apps that have the SDK installed
has_ad_spend | **boolean** <br>If true, the result will only include apps that we know are advertising on Facebook
order_by | **string** <br>Order results by field. Must be one of:<br><code>first_scanned_date</code><br><code>last_scanned_date</code><br><code>last_updated</code>.<br>By default, results are in ascending order. Include <code>-</code> in front of the value to order results in descending order e.g. <code>-first_scanned_date</code>

You can use the [MightySignal web portal](http://mightysignal.com/app/app) to find the ids for the query parameters.

For example, the `publisher_id` would be `12` for Uber Technlogies, Inc. since its MightySignal link is [http://mightysignal.com/app/app#/publisher/android/12](http://mightysignal.com/app/app#/publisher/android/12), and the `installed_sdk_id` for Crashlytics would be `7` since its MightySignal link is [http://mightysignal.com/app/app#/sdk/android/7](http://mightysignal.com/app/app#/sdk/android/7).

Alternatively, if you know of an app that meets the criteria (i.e. has a certain SDK or by a certain publisher), use the [simple app route](#filter-on-android-apps) and pluck the IDs off the response.

<aside class="notice">
You can specify multiple values for a given query parameter, and they will be treated like an OR statement. For example, passing the query string <code>?installed_sdk_id=1,2&publisher_id=10</code> will only return apps by publisher with id 10 that have installed the Android SDK with id 1 or the Android SDK with id 2.
</aside>

### Response

Key | Description
--- | -----------
results_count | See [Pagination](#pagination)
total_results_count | See [Pagination](#pagination)
page | See [Pagination](#pagination)
total_page_count | See [Pagination](#pagination)
page_size | See [Pagination](#pagination)
apps | An array of Android apps. You can look at the response format [here](#get-information-about-a-specific-app6)


### Notes

* Your query results will often return a large number of apps and you will be required to page through all the responses. See the [Pagination](#pagination) section for more information.

# SDKs

## Get information about an SDK

> Example: Get information about the Alamofire iOS SDK

```bash
curl "https://api.mightysignal.com/ios/sdk/153"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
    "id": 153,
    "platform": "ios",
    "name": "Alamofire",
    "website": "https://github.com/Alamofire/Alamofire",
    "categories": [
        "Networking"
    ],
    "apps_count": 34253
}
```

### HTTP Request Format

`GET /<platform>/sdk/<sdk_id>`

where `<platform>` is either `ios` or `android` and `<sdk_id>` is the MightySignal id of the SDK.

One way to find the `<sdk_id>` is by using the [MightySignal web portal](http://mightysignal.com/app/app). For example, the `<sdk_id>` for the Mixpanel iOS SDK would be `1896` since its MightySignal link is [http://mightysignal.com/app/app#/sdk/ios/1896](http://mightysignal.com/app/app#/sdk/ios/1896).

You can also use the responses from the [iOS](#ios-apps) or [Android](#android-apps) app routes to find the `<sdk_id>`.

<aside class="notice">
SDK IDs are unique <i>by platform</i>. So, <code>/android/sdk/1</code> and <code>/ios/sdk/1</code> will return information about different SDKs
</aside>

### Response

Key | Description
--- | -----------
id | The MightySignal ID of the SDK. It's recommended you store this so you can reference the SDK easily.
apps_count | The number of apps that contain this SDK for the given platform (iOS or Android)
platform | `ios` or `android`
summary | Brief description of the SDK
website | Website of the SDK
categories | The categories of this SDK.

# Publishers

Publishers are specific to a given platform (iOS or Android). Each iOS app has an iOS publisher, and that iOS publisher can have many iOS apps. Each Android app has an Android publisher, and that Android publisher can have many Android apps.

## Get information about a specific publisher

> Example: Retrieve the latest information about Shazam (for iOS)

```bash
curl "https://api.mightysignal.com/ios/publisher/207911"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
   "app_store_id" : 284993479,
   "websites" : [
      "http://www.shazam.com/iphone",
      "http://www.shazam.com",
      "http://www.shazam.com/music/web/faqs.html?platform=iPhone"
   ],
   "name" : "Shazam Entertainment Limited",
   "platform" : "ios",
   "id" : 207911,
   "details" : [
      {
         "linkedin_handle" : "company/shazam-entertainment",
         "street_number" : "26",
         "crunchbase_handle" : "organization/shazam-entertainment",
         "country_code" : "GB",
         "ticker" : null,
         "state" : "England",
         "industry_group" : "Technology Hardware & Equipment",
         "postal_code" : "W6 7HA",
         "sub_industry" : "Technology Hardware, Storage & Peripherals",
         "facebook_handle" : "shazam",
         "lng" : "-0.226008",
         "google_rank" : null,
         "name" : "Shazam",
         "sector" : "Information Technology",
         "description" : "Identify the media playing around you, explore the music and TV you love. Discover song lyrics from your favourite artists and albums on Shazam!",
         "twitter_handle" : "Shazam",
         "market_cap" : null,
         "sub_premise" : null,
         "employees" : 321,
         "lat" : "51.494715",
         "twitter_id" : "14772687",
         "alexa_global_rank" : 5944,
         "domain" : "shazam.com",
         "city" : "London",
         "utc_offset" : 1,
         "founded_year" : 1999,
         "company_type" : "private",
         "employees_range" : "251-1000",
         "country" : "United Kingdom",
         "alexa_us_rank" : 5993,
         "street_name" : "Hammersmith Grove",
         "raised" : 136000000,
         "phone" : null,
         "industry" : "Communications Equipment",
         "logo_url" : "https://logo.clearbit.com/shazam.com",
         "annual_revenue" : null,
         "tags" : [
            "Mobile",
            "B2C",
            "Music",
            "Entertainment & Recreation",
            "Entertainment"
         ],
         "email_provider" : false,
         "time_zone" : "Europe/London",
         "state_code" : "England",
         "tech_used" : [
            "facebook_connect",
            "wordpress",
            "mailgun",
            "android",
            "google_apps",
            "youtube",
            "aws_route_53",
            "nginx",
            "ios"
         ],
         "legal_name" : "Shazam Entertainment Ltd."
      }
   ]
}
```

### HTTP Request Format (iOS)

`GET /ios/publisher/<publisher_id>`

where `<publisher_id>` is the MightySignal ID of the iOS publisher. You can get it from the MightySignal publisher page (eg. [http://mightysignal.com/app/app#/publisher/ios/207911](http://mightysignal.com/app/app#/publisher/ios/207911)) or from the `publisher.id` field from the JSON for an iOS app.

### HTTP Request Format (Android)

`GET /android/publisher/<publisher_id>`

where `<publisher_id>` is the MightySignal ID of the Android publisher. You can get it from the MightySignal publisher page (eg. [http://mightysignal.com/app/app#/publisher/android/1162](http://mightysignal.com/app/app#/publisher/android/1162)) or from the `publisher.id` field from the JSON for an Android app.

### Response

Key | Description
--- | -----------
app_store_id _or_ google_play_id | The App Store ID or Google Google Play ID of the publisher
websites | An array of all websites of all apps of the publisher
name | The name of the publisher
platform | `ios` or `android`
id | The MightySignal ID of the publisher
details.linkedin_handle | LinkedIn handle
details.street_number | Street number
details.crunchbase_handle | Crunchbase handle
details.country_code | Country code of the country where the publisher is located
details.ticker | Stock symbol
details.state | State where the publisher is located
details.industry_group | Industry
details.postal_code | Postal code of the publisher's location
details.sub_industry | Sub-industry
details.facebook_handle | Facebook handle
details.lng | Longitude of the publisher's location
details.google_rank | Rank on Google
details.name | Name
details.sector | Sector
details.description | Description
details.twitter_handle | Twitter handle
details.market_cap | Market cap
details.sub_premise | Location suite number
details.employees | Number of employees
details.alexa_global_rank | Global Alexa rank
details.domain | Domain
details.city | City where the publisher is located
details.utc_offset | UTC offset of the publisher's location
details.founded_year | Year the publisher was founded
details.company_type | Type of company
details.employees_range | Range of employees , eg. `251-1000`
details.country | Country where the publisher is located
details.alexa_us_rank | US Alexa rank
details.street_name | Street name
details.raised | Money raised ($)
details.phone | Phone number
details.industry | Industry
details.logo_url | URL of logo
details.annual_revenue | Annual revenue ($)
details.tags | Array of tags describing the publisher's business
details.email_provider | Whether the domain is an email provider
details.time_zone | Time zone of the location
details.state_code | The state code of the location
details.tech_used | Array of web technologies on the developer's website
details.legal_name | Legal name

## Lookup a publisher by domain

> Example: Retrieve the publisher who owns the domain `snapchat.com`

```bash
curl "https://api.mightysignal.com/ios/publisher?domain=snapchat.com"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
[
   {
      "id" : 249735,
      "name" : "Snapchat, Inc.",
      "platform" : "ios",
      "app_store_id" : 446889612
   }
]
```

### HTTP Request Format (iOS)

`GET /ios/publisher?domain=<domain>`

where `<domain>` is the domain in question. Make sure to use only the domain, and not the scheme (i.e `http/s`), subdomains, or path

### HTTP Request Format (Android)

`GET /android/publisher?domain=<domain>`

where `<domain>` is the domain in question. Make sure to use only the domain, and not the scheme (i.e `http/s`), subdomains, or path

## Lookup publisher contacts

> Example: Retrieve the contacts of the Android publisher with ID 360

```bash
curl "https://api.mightysignal.com/ios/publisher/360/contacts"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
[
  {
    "clearbitId"=>"e_d6d2f126-a158-4eee-b44a-de7105867179",
    "givenName"=>"katherine",
    "familyName"=>"tassi",
    "fullName"=>"Katherine Tassi",
    "title"=>"Managing Counsel, Privacy",
    "email"=>"katherine.tassi@uber.com",
    "linkedin"=>"https://www.linkedin.com/in/katherinetassi"
  },
  {
    "clearbitId"=>"e_a88f586d-74f1-4d49-85b0-7763f11d3804",
    "givenName"=>"mary",
    "familyName"=>"demyanritti",
    "fullName"=>"Mary Ritti",
    "title"=>"VP Communications",
    "email"=>"mary@snap.com",
    "linkedin"=>"in/maryritti"
  }
]
```

### HTTP Request Format (iOS)

`GET /ios/publisher/<publisher_id>/contacts`

where `<publisher_id>` is the MightySignal ID of the iOS publisher. You can get it from the MightySignal publisher page (eg. [http://mightysignal.com/app/app#/publisher/ios/207911](http://mightysignal.com/app/app#/publisher/ios/207911)) or from the `publisher.id` field from the JSON for an iOS app.

### HTTP Request Format (Android)

`GET /android/publisher/<publisher_id>/contacts`

where `<publisher_id>` is the MightySignal ID of the Android publisher. You can get it from the MightySignal publisher page (eg. [http://mightysignal.com/app/app#/publisher/android/1162](http://mightysignal.com/app/app#/publisher/android/1162)) or from the `publisher.id` field from the JSON for an Android app.

# Pagination

> Example: [Alamofire](https://github.com/Alamofire/Alamofire) is a ubiquitous iOS SDK. To get all apps using Alamofire, you will need to page through the results.

> The first set of results will tell you the total number of results and pages.

```bash
curl "https://api.mightysignal.com/ios/app?installed_sdk_id=153"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
        "apps": ["..."],
        "page": 1,
        "page_size": 25,
        "results_count": 25,
        "total_page_count": 3859,
        "total_results_count": 96454
}
```

> You have the 25 results on the first page. There are 96,454 total apps and 3,859 pages of the current page size. To get the next set of results, pass the `page` query param.

```bash
curl "https://api.mightysignal.com/ios/app?installed_sdk_id=153&page=2"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
        "apps": ["..."],
        "page": 2,
        "page_size": 25,
        "results_count": 25,
        "total_page_count": 3859,
        "total_results_count": 96454
}
```

Routes with a large number of results will be paged and API clients will have to iterate through each page to get all results. Routes that support paging will return page meta information along with the results. Using the query parameters `page` and `page_size`, you can iterate through all pages.

### Query Parameters
Parameter | Default | Description
--------- | ------- | -----------
page | 1 | The page number to return (1-indexed). Unless specified, will always return the first page
page_size | 25 | The number of results to return per page. (max: 50)

### Page Meta Information

Key | Description
--- | -----------
page | The current page of results (configurable by query param)
page_size | The maximum number of results that was returned per page (configurable by query param)
results_count | The number of results on the current page
total_page_count | The total number of pages for *all* results given the current page size
total_results_count | The total number of results that meet the given query


# Rate limiting

Every API token has a limited number of requests it can make in a certain timeframe. Use the rate limit route to see what your token's limits are.

> Example: See your token's limits

```bash
curl "https://api.mightysignal.com/rate-limit"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
    "count": 1,
    "limit": 2500,
    "period": 3600
}
```

### HTTP Request Format

`GET /rate-limit`

### Rate limit information

Key | Description
--- | -----------
count | The number of requests made using the given token during the current window
limit | The maximum number of requests allowable in the window for the current token
period | The length of the request window (in seconds)

> This token has a limit of 2500 requests per hour (hour = 3600 seconds) and only 1 request has been made against it.

<aside class="notice">
Requests to the rate limit route <b>will not</b> count against your number of requests.
</aside>

### Notes

* This rate limit hopes to minimize the damage caused by abusive or misconfigured scripting clients, not to restrict legitimate use cases. Please [let us know](mailto:support@mightysignal.com) if this limit restricts your workflow, and we can work with you to increase your limit.

# Summary Responses

> First, see a set of  apps using the Parse iOS SDK.

```bash
curl "https://api.mightysignal.com/ios/app?installed_sdk_id=2362"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
  "apps" : [
    "...",
      {
        "rating" : "4.5",
        "seller" : "Tapps Tecnologia da Informacao LTDA.",
        "last_updated" : "2016-02-10",
        "first_seen_ads_date" : "2016-01-15",
        "last_seen_ads_date" : "2016-02-30",
        "first_scanned_date" : "2016-05-15",
        "last_scanned_date" : "2016-07-08",
        "user_base" : "moderate",
        "support_url" : "http://tappsgames.com/contact/",
        "publisher" : {
           "platform" : "ios",
           "id" : 10795,
           "name" : "Tapps Tecnologia da Informacao LTDA."
        },
        "has_in_app_purchases" : true,
        "original_release_date" : "2011-07-18",
        "name" : "Snake ~ Best Free Classic Worm and Serpent Game",
        "mobile_priority" : "medium",
        "app_store_id" : 446768343,
        "platform" : "ios",
        "has_ad_spend" : false,
        "current_version_rating" : "4.0",
        "current_version_ratings_count" : 200,
        "all_version_rating" : "4.0",
        "all_version_ratings_count" : 2000,
        "id" : 1001590,
        "price" : 0,
        "categories" : [
          "..."
        ],
        "current_version" : "1.6.5"
      },
      "..."
   ],
   "total_results_count" : 25849,
   "results_count" : 25,
   "total_page_count" : 1034,
   "page_size" : 25,
   "page" : 1
}
```

> The above is a summary representation of an iOS game. Notice how it only has a subset of the information (i.e. does not have installed or uninstalled SDKs). To get the full information, call the iOS app getter route with the `app_store_id` from the above response.

```bash
curl "https://api.mightysignal.com/ios/app/446768343"
    -H "MIGHTYSIGNAL-TOKEN: <your-api-token>"
```

```json
{
  "name" : "Snake ~ Best Free Classic Worm and Serpent Game",
  "original_release_date" : "2011-07-18",
  "seller" : "Tapps Tecnologia da Informacao LTDA.",
  "price" : 0,
  "categories" : [
   "..."
  ],
  "publisher" : {
     "platform" : "ios",
     "id" : 10795,
     "name" : "Tapps Tecnologia da Informacao LTDA."
  },
  "current_version" : "1.6.10",
  "last_updated" : "2016-08-02",
  "first_seen_ads_date" : "2016-01-15",
  "last_seen_ads_date" : "2016-02-30",
  "first_scanned_date" : "2016-05-15",
  "last_scanned_date" : "2016-07-08",
  "id" : 1001590,
  "uninstalled_sdks" : [],
  "app_store_id" : 446768343,
  "has_in_app_purchases" : true,
  "current_version_rating" : "4.5",
  "current_version_ratings_count" : 8,
  "all_version_rating" : "4.5",
  "all_version_ratings_count" : 1486,
  "installed_sdks" : [
    {
      "first_seen_date" : "2016-02-17T18:16:57.000Z",
      "last_seen_date" : "2016-08-13T04:12:50.000Z",
      "id" : 35,
      "name" : "AdColony"
    },
    "..."
   ],
   "uninstalled_sdks" : [
    {
      "first_seen_date" : "2016-02-17T18:16:57.000Z",
      "name" : "Playhaven",
      "last_seen_date" : "2016-06-19T15:50:51.000Z",
      "id" : 3808
    },
    "..."
   ],
   "user_base" : "moderate",
   "support_url" : "http://tappsgames.com/contact/",
   "mobile_priority" : "medium",
   "has_ad_spend" : false,
   "platform" : "ios"
}
```

> This full response has all information, including SDK installs and uninstalls.

Some resources have properties which are computationally intensive to calculate (eg. apps and their SDK install histories). Fetching a <i>list</i> of those resources puts a significant strain on our ability to support all API clients simultaneously.

For that reason, certain routes show <b>summary</b> representation of responses, which means it includes a subset of the entire information about the resource. This is often enough information, but making another request to the basic GET request for that resource will return the full information.

See the adjacent walkthrough example for a sample workflow.

# Bugs? Questions?

[Email us](mailto:support@mightysignal.com) if you have any questions or encounter any bugs.

If reporting a bug, please include the following information to help us diagnose the problem:

*  The request(s) called (ex. `https://api.mightysignal.com/ios/app/1`)
*  The received response
*  The expected response or a description of what went wrong
