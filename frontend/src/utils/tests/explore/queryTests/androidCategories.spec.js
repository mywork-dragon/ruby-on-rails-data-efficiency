/* eslint-env jest */

import { buildCategoryFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const filters = {
    androidCategories: {
      value: [{ value: 'GAME_EDUCATIONAL', label: 'Game Education' }, { value: 'GAME_CARD' }],
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
              ['platform', 'android'],
              [
                'or',
                ['id', 'GAME_EDUCATIONAL'],
                ['id', 'GAME_CARD'],
              ],
            ],
          },
          {
            operator: 'filter',
            object: 'app',
            predicates: [
              ['platform', 'android'],
            ],
          },
        ],
      },
    ],
  };

  const appFilter = buildCategoryFilters(filters);

  expect(appFilter).toMatchObject(expected);
});
