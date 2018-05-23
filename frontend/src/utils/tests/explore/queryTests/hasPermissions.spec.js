/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      appPermissions: {
        value: [
          { value: 'locations_foreground', label: 'Location (foreground)' },
          { value: 'locations_background', label: 'Location (background)' },
        ],
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
        ['has_permission', 'locations_foreground'],
        ['has_permission', 'locations_background'],
      ],
    ],
  };

  const result = buildAppFilters(form);

  expect(result).toMatchObject(expected);
});
