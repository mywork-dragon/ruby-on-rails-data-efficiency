/* eslint-env jest */

import { buildCategoryFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'all',
    filters: {
      categories: {
        value: [
          { value: 'GAME_EDUCATIONAL', label: 'Game Education', android: 'GAME_EDUCATIONAL' },
          { value: 'GAME_CARD', android: 'GAME_CARD' },
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

  const appFilter = buildCategoryFilters(form);

  expect(appFilter).toMatchObject(expected);
});
