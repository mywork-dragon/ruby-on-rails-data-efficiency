/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      rating: {
        value: {
          value: [0, 4.0],
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
      ['all_version_rating', 0, 3.9],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
