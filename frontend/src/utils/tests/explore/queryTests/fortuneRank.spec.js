/* eslint-env jest */

import { buildPublisherFilters } from '../../../explore/filterBuilder.utils';

test('', () => {
  const form = {
    platform: 'ios',
    includeTakenDown: false,
    filters: {
      fortuneRank: {
        value: 500,
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'publisher',
    predicates: [
      ['or',
        ['fortune_rank', 0, 500],
      ],
    ],
  };

  const publisherFilter = buildPublisherFilters(form);

  expect(publisherFilter).toMatchObject(expected);
});
