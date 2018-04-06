/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      availableCountries: {
        value: {
          countries: [
            { key: 'US', label: 'United States' },
            { key: 'JP', label: 'Japan' },
          ],
          operator: 'all',
          condition: 'not-available-in',
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
        [
          'and',
          ['not', ['available_in', 'US']],
          ['not', ['available_in', 'JP']],
        ],
        ['platform', 'android'],
      ],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
