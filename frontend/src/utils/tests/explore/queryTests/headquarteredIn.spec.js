/* eslint-env jest */

import { buildPublisherFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      headquarters: {
        value: [
          { key: 'US', label: 'United States' },
          { key: 'CA', label: 'Canada' },
        ],
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'publisher',
    predicates: [
      ['or',
        ['country_code', 'US'],
        ['country_code', 'CA'],
      ],
    ],
  };

  const appFilter = buildPublisherFilters(form);

  expect(appFilter).toMatchObject(expected);
});
