/* eslint-env jest */

import { buildAdNetworkFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    filters: {
      adNetworks: {
        value: {
          adNetworks: [
            { key: 'applovin', label: 'Applovin' },
            { key: 'unity-ads', label: 'Unity' },
          ],
          operator: 'all',
          firstSeenDateRange: 'anytime',
          lastSeenDateRange: 'after-date',
          firstSeenDate: '2018-01-01',
          lastSeenDate: '2018-01-01',
        },
      },
    },
  };

  const expected = {
    operator: 'intersect',
    inputs: [
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'applovin'],
          [
            'last_seen_ads_date',
            '2018-01-01',
            null,
          ],
        ],
      },
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'unity-ads'],
          [
            'last_seen_ads_date',
            '2018-01-01',
            null,
          ],
        ],
      },
    ],
  };

  const result = buildAdNetworkFilters(form.filters);

  expect(result).toMatchObject(expected);
});

test('', () => {
  const form = {
    filters: {
      adNetworks: {
        value: {
          adNetworks: [
            { key: 'applovin', label: 'Applovin' },
            { key: 'unity-ads', label: 'Unity' },
          ],
          operator: 'any',
          firstSeenDateRange: 'before-date',
          lastSeenDateRange: 'anytime',
          firstSeenDate: '2018-01-01',
          lastSeenDate: '2018-01-01',
        },
      },
    },
  };

  const expected = {
    operator: 'union',
    inputs: [
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'applovin'],
          [
            'first_seen_ads_date',
            null,
            '2018-01-01',
          ],
        ],
      },
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'unity-ads'],
          [
            'first_seen_ads_date',
            null,
            '2018-01-01',
          ],
        ],
      },
    ],
  };

  const result = buildAdNetworkFilters(form.filters);

  expect(result).toMatchObject(expected);
});
