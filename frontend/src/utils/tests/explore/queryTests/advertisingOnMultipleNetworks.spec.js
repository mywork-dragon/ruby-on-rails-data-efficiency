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
          operator: 'and',
          firstSeenDateRange: 'anytime',
          lastSeenDateRange: 'anytime',
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
          firstSeenDateRange: 'anytime',
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
        ],
      },
      {
        operator: 'filter',
        object: 'mobile_ad_data_summary',
        predicates: [
          ['ad_network', 'unity-ads'],
        ],
      },
    ],
  };

  const result = buildAdNetworkFilters(form.filters);

  expect(result).toMatchObject(expected);
});
