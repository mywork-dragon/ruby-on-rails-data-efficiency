/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      ratingsCount: {
        value: {
          value: [10000, null],
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
      ['all_version_ratings_count', 10000, null],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      ratingsCount: {
        value: {
          value: [0, undefined],
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
      ['all_version_ratings_count', 0, null],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
