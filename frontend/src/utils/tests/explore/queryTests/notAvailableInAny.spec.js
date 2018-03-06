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
        ['not', ['available_in', 'US']],
        ['not', ['available_in', 'JP']],
      ],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
