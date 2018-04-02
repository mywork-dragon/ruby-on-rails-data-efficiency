/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      downloads: {
        value: {
          value: [50000, 10000000],
          operator: 'between',
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
      [
        'or',
        ['downloaded', 50000, 10000000],
        ['platform', 'ios'],
      ],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
