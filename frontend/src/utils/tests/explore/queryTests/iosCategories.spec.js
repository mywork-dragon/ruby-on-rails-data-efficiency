/* eslint-env jest */

import { buildCategoryFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const filters = {
    iosCategories: {
      value: [{ value: '36', label: 'Overall' }, { value: '6016', label: 'Games' }],
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

  const appFilter = buildCategoryFilters(filters);

  expect(appFilter).toMatchObject(expected);
});