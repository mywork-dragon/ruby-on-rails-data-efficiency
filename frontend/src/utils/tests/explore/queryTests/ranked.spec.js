/* eslint-env jest */

import { buildRankingsFilters } from 'utils/explore/filterBuilder.utils';

test('apps that are ranked above 100', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'rank' },
          dateRange: 'one-week',
          operator: 'more-than',
          trendOperator: 'up',
          values: [100, null],
          charts: 'free',
          iosCategories: [{ value: 36, label: 'Overall' }],
          androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
          countries: 'US,FR',
        },
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
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
      ['rank', null, 100],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that are ranked below 500', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'rank' },
          dateRange: 'week',
          operator: 'less-than',
          trendOperator: 'up',
          values: [0, 500],
          charts: 'free',
          iosCategories: [{ value: 36, label: 'Overall' }],
          androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
          countries: 'US,FR',
        },
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
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
        ['rank', 500, null],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that are ranked between 100 and 500', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'rank' },
          dateRange: 'one-week',
          operator: 'between',
          trendOperator: 'up',
          values: [100, 500],
          charts: 'free',
          iosCategories: [{ value: 36, label: 'Overall' }],
          androidCategories: [{ value: 'OVERALL', label: 'Overall' }],
          countries: 'US,FR',
        },
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
        ['ranking_type', 'free'],
      ],
      [
        'or',
        ['category', 'OVERALL'],
        ['category', 36],
      ],
      ['rank', 100, 500],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('generate a default sort', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: '' },
          values: [],
          charts: 'free',
          countries: 'US,FR',
        },
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
        ['ranking_type', 'free'],
      ],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});
