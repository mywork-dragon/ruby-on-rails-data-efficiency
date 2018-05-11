/* eslint-env jest */

import { buildCategoryFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'all',
    filters: {
      categories: {
        value: [
          { value: '36', label: 'Overall', ios: '36' },
          { value: '6016', label: 'Games', ios: '6016' },
        ],
      },
    },
  };

  const expected = {
    operator: 'union',
    inputs: [
      {
        operator: 'intersect',
        inputs: [
          {
            operator: 'filter',
            object: 'app_category',
            predicates: [
              ['platform', 'ios'],
              [
                'or',
                ['id', '36'],
                ['id', '6016'],
              ],
            ],
          },
          {
            operator: 'filter',
            object: 'app',
            predicates: [
              ['platform', 'ios'],
            ],
          },
        ],
      },
    ],
  };

  const appFilter = buildCategoryFilters(form);

  expect(appFilter).toMatchObject(expected);
});
