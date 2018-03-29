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
        ],
      },
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'unity-ads'],
        ],
      },
      {
        operator: 'filter',
        object: 'app',
        predicates: [
          [
            'last_seen_ads_date',
            '2018-01-01',
            null,
            ['applovin', 'unity-ads'],
          ],
        ],
      },
    ],
  };

  const result = buildAdNetworkFilters(form.filters);

  expect(result).toMatchObject(expected);
});
