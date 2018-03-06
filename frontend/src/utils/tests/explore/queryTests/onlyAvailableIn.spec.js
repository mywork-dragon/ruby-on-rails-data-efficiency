/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      availableCountries: {
        value: {
          countries: [{ key: 'US', label: 'United States' }],
          operator: 'any',
          condition: 'only-available-in',
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
      ['only_available_in_country', 'US'],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});

test('defaults to only available in if no condition provided', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      availableCountries: {
        value: {
          countries: [{ key: 'US', label: 'United States' }],
          operator: 'any',
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
      ['only_available_in_country', 'US'],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
