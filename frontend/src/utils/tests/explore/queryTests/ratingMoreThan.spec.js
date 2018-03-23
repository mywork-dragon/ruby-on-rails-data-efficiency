/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      rating: {
        value: {
          value: [3.5, null],
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
      ['all_version_rating', 3.5, null],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});