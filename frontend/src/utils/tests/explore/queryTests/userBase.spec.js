/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      userBase: {
        value: ['strong', 'elite'],
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'app',
    predicates: [
      ['platform', 'ios'],
      ['not', ['taken_down']],
      ['or',
        ['user_base', 'strong'],
        ['user_base', 'elite'],
      ],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
