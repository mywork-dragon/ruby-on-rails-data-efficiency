/* eslint-env jest */

import { buildPublisherFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    resultType: 'publisher',
    includeTakenDown: false,
    filters: {
      adNetworkCount: {
        value: {
          value: [0, 4],
          operator: 'less-than',
        },
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'publisher',
    predicates: [
      ['count_advertising_networks', null, 4],
    ],
  };

  const result = buildPublisherFilters(form);

  expect(result).toMatchObject(expected);
});
