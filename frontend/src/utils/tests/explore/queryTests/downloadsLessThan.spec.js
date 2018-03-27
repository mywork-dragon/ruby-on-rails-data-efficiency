/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      downloads: {
        value: {
          value: [0, 10000000],
          operator: 'less-than',
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
      ['downloaded', 0, 10000000],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
