/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      adNetworkCount: {
        value: {
          start: 2,
          end: 4,
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
      ['count_advertising_networks', 2, 4],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
