/* eslint-env jest */

import { buildAdIntelFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const filters = {
    creativeFormats: {
      value: ['html_game', 'video', 'other_formats'],
    },
  };

  const expected = {
    operator: 'filter',
    object: 'mobile_ad_data_summary',
    predicates: [
      [
        'or',
        ['html_game'],
        ['video'],
        ['other_formats'],
      ],
    ],
  };

  const filter = buildAdIntelFilters(filters);

  expect(filter).toMatchObject(expected);
});
