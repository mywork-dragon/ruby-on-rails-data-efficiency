/* eslint-env jest */

import { buildRankingsFilters } from 'utils/explore/filterBuilder.utils';

test('apps that first appeared on a chart in the past week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        eventType: 'newcomer',
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
      ['created_at', ['-', ['utcnow'], ['timedelta', { days: 7 }]]],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that first appeared on a chart in the past two days', () => {
  const form = {
    filters: {
      rankings: {
        eventType: 'newcomer',
        dateRange: 'two-day',
        operator: 'less-than',
        trendOperator: 'up',
        values: [0, 500],
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
      ['created_at', ['-', ['utcnow'], ['timedelta', { days: 2 }]]],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});
