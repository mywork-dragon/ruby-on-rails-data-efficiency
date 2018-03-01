/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      mobilePriority: {
        value: ['medium', 'high'],
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
        ['mobile_priority', 'medium'],
        ['mobile_priority', 'high'],
      ],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
