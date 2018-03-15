/* eslint-env jest */

import { buildAdNetworkFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    filters: {
      adNetworks: {
        value: {
          adNetworks: [{ key: 'applovin', label: 'Applovin' }],
          operator: 'all',
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
    inputs: [{
      operator: 'filter',
      object: 'mobile_ad_data_summary',
      predicates: [
        ['ad_network', 'applovin'],
      ],
    }],
  };

  const result = buildAdNetworkFilters(form.filters);

  expect(result).toMatchObject(expected);
});
