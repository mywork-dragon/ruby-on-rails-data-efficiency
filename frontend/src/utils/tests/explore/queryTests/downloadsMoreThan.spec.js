/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      downloads: {
        value: {
          value: [10000000, null],
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
      ['downloaded', 10000000, null],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});