/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      releaseDate: {
        value: {
          dateRange: 'week',
          dates: ['2017-10-01', '2017-12-01'],
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
        'released',
        ['-', ['utcnow'], ['timedelta', { days: 7 }]],
        ['utcnow'],
      ],
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
      releaseDate: {
        value: {
          dateRange: 'custom',
          dates: ['2017-10-01', '2017-12-01'],
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
        'released',
        '2017-10-01',
        '2017-12-01',
      ],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});

