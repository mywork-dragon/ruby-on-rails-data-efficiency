/* eslint-env jest */

import { buildRankingsFilters } from 'utils/explore/filterBuilder.utils';

test('apps that are ranked above 100', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        eventType: 'rank', // app is ranked
        dateRange: 'one-week', // ignored for rank
        operator: 'more-than', // ranked above
        trendOperator: 'up', // ignored for rank
        values: [100, null], // rank range
        charts: 'free',
        iosCategories: [{ value: 36, label: 'Overall' }],
        androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
        countries: 'US,FR',
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'ranking',
    predicates: [
      [
        'or',
        ['country', 'US'],
        ['country', 'FR'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
      [
        'or',
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['rank', 100, null],
      ],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that are ranked below 500', () => {
  const form = {
    filters: {
      rankings: {
        eventType: 'rank', // app is ranked
        dateRange: 'one-week', // ignored for rank
        operator: 'less-than', // ranked below
        trendOperator: 'up', // ignored for rank
        values: [0, 500], // rank range
        charts: 'free',
        iosCategories: [{ value: 36, label: 'Overall' }],
        androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
        countries: 'US,FR',
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'ranking',
    predicates: [
      [
        'or',
        ['country', 'US'],
        ['country', 'FR'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
      [
        'or',
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['rank', null, 500],
      ],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that are ranked between 100 and 500', () => {
  const form = {
    filters: {
      rankings: {
        eventType: 'rank', // app is ranked
        dateRange: 'one-week', // ignored for rank
        operator: 'between', // ranked between
        trendOperator: 'up', // ignored for rank
        values: [100, 500], // rank range
        charts: 'free',
        iosCategories: [{ value: 36, label: 'Overall' }],
        androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
        countries: 'US,FR',
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'ranking',
    predicates: [
      [
        'or',
        ['country', 'US'],
        ['country', 'FR'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
      [
        'or',
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['rank', 100, 500],
      ],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});
