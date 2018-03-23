/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      ratingsCount: {
        value: {
          value: [1000, 10000],
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
      ['all_version_ratings_count', 1000, 10000],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
