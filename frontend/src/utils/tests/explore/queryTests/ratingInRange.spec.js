/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      rating: {
        value: {
          value: [2.0, 4.0],
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
      ['all_version_rating', 2, 4],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
