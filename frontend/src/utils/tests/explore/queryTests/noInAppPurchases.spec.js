/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      inAppPurchases: {
        value: 'no',
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'app',
    predicates: [
      ['platform', 'ios'],
      ['not', ['taken_down']],
      ['not', ['in_app_purchases']],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
