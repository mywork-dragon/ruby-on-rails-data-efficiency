/* eslint-env jest */

import { buildAdNetworkFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    resultType: 'app',
    filters: {
      adNetworks: {
        value: {
          adNetworks: [
            { key: 'applovin', label: 'Applovin' },
            { key: 'unity-ads', label: 'Unity' },
          ],
          operator: 'any',
          firstSeenDateRange: 'anytime',
          lastSeenDateRange: 'after-date',
          firstSeenDate: '2018-01-01',
          lastSeenDate: '2018-01-01',
        },
      },
    },
  };

  const expected = {
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
  };

  const result = buildAdNetworkFilters(form);

  expect(result).toMatchObject(expected);
});
