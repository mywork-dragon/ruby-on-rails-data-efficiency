/* eslint-env jest */

import { buildRankingsFilters } from 'utils/explore/filterBuilder.utils';

test('apps that have moved up more than 100 places in the last week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'trend' },
          dateRange: { value: 'week', label: 'Week' },
          operator: 'more-than',
          trendOperator: 'up',
          values: [100, null],
          charts: 'free',
          categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
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
        ['category', '36'],
        ['category', 'OVERALL'],
      ],
      ['weekly_change', 100, null],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that have moved up less than 500 places in the last month', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'trend' },
          dateRange: { value: 'month', label: 'Month' },
          operator: 'less-than',
          trendOperator: 'up',
          values: [0, 500],
          charts: 'free',
          categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
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
        ['category', '36'],
        ['category', 'OVERALL'],
      ],
      ['monthly_change', 0, 500],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that have moved up between 100 and 500 places in the last week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'trend' },
          dateRange: { value: 'week', label: 'Week' },
          operator: 'between',
          trendOperator: 'up',
          values: [100, 500],
          charts: 'free',
          categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
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
        ['category', '36'],
        ['category', 'OVERALL'],
      ],
      ['weekly_change', 100, 500],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that have moved down more than 300 places in the last week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'trend' },
          dateRange: { value: 'week', label: 'Week' },
          operator: 'between',
          trendOperator: 'down',
          values: [300, null],
          charts: 'free',
          categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
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
        ['category', '36'],
        ['category', 'OVERALL'],
      ],
      ['weekly_change', null, -300],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});

test('apps that have moved down less than 100 places in the last week', () => {
  const form = {
    platform: 'all',
    filters: {
      rankings: {
        value: {
          eventType: { value: 'trend' },
          dateRange: { value: 'week', label: 'Week' },
          operator: 'between',
          trendOperator: 'down',
          values: [0, 100],
          charts: 'free',
          categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
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
        ['category', '36'],
        ['category', 'OVERALL'],
      ],
      ['weekly_change', -100, 0],
    ],
  };

  const result = buildRankingsFilters(form);

  expect(result).toMatchObject(expected);
});
