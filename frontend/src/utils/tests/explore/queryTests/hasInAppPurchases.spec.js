/* eslint-env jest */

import { buildAppFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      inAppPurchases: {
        value: 'yes',
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'app',
    predicates: [
      ['platform', 'ios'],
      ['not', ['taken_down']],
      ['in_app_purchases'],
    ],
  };

  const appFilter = buildAppFilters(form);

  expect(appFilter).toMatchObject(expected);
});
