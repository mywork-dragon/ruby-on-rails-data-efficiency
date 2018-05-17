/* eslint-env jest */

import { buildHeadquarterFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      headquarters: {
        value: {
          values: [
            { value: 'San Francisco', label: 'San Francisco', city: 'San Francisco', state: 'CA', country: 'US' },
            { value: 'Hong Kong', label: 'Hong Kong', city: 'Hong Kong', state: null, country: 'HK' },
            { value: 'CA', label: 'California', state: 'CA', country: 'US' },
            { value: 'RU', label: 'Russia', country: 'RU' },
          ],
          operator: 'any',
          includeNoHqData: false,
        },
      },
    },
  };

  const expected = {
    operator: 'union',
    inputs: [
      {
        operator: 'filter',
        object: 'publisher',
        predicates: [
          [
            'and',
            ['city', 'San Francisco'],
            ['state_code', 'CA'],
            ['country_code', 'US'],
          ],
        ],
      },
      {
        operator: 'filter',
        object: 'publisher',
        predicates: [
          [
            'and',
            ['city', 'Hong Kong'],
            ['country_code', 'HK'],
          ],
        ],
      },
      {
        operator: 'filter',
        object: 'publisher',
        predicates: [
          [
            'and',
            ['state_code', 'CA'],
            ['country_code', 'US'],
          ],
        ],
      },
      {
        operator: 'filter',
        object: 'publisher',
        predicates: [
          [
            'and',
            ['country_code', 'RU'],
          ],
        ],
      },
    ],
  };

  const result = buildHeadquarterFilters(form.filters);

  expect(result).toMatchObject(expected);
});
