/* eslint-env jest */

import { buildRankingsFilters } from 'utils/explore/filterBuilder.utils';

test('apps that first appeared on a chart in the past week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'newcomer' },
          dateRange: { value: 'week', label: 'Week' },
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
    object: 'newcomer',
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
      [
        'created_at',
        [
          '-',
          ['utcnow'],
          ['timedelta', { days: 7 }],
        ],
        ['utcnow'],
      ],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that first appeared on a chart in the past two days', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'newcomer' },
          dateRange: { value: 'two-day', label: 'Two Days' },
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
    object: 'newcomer',
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
      [
        'created_at',
        [
          '-',
          ['utcnow'],
          ['timedelta', { days: 2 }],
        ],
        ['utcnow'],
      ],
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
          eventType: { value: 'newcomer' },
          values: [],
          charts: 'free',
          countries: 'US,FR',
        },
      },
    },
  };

  const expected = {
    operator: 'filter',
    object: 'newcomer',
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
