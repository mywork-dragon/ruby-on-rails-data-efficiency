/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      adNetworkCount: {
        value: {
          value: [3, null],
          operator: 'more-than',
        },
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'app',
    predicates: [
      ['platform', 'ios'],
      ['not', ['taken_down']],
      ['count_advertising_networks', 3, null],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});