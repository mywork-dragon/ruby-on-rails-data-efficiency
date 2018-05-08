import _ from 'lodash';
import { headerNames } from 'Table/redux/column.models';
import { getNestedValue } from 'utils/format.utils';
import { buildRankingsFilters } from './filterBuilder.utils';

export function buildSortSettings (sorts, form) {
  const result = { fields: [] };
  const { resultType } = form;
  const defaultSorts = [
    {
      field: 'id',
      object: 'app',
      order: 'asc',
    },
    {
      field: 'platform',
      object: 'app',
      order: 'asc',
    },
  ];

  const formattedSorts = convertToQuerySort(sorts, form);

  if (!formattedSorts.length) {
    if (resultType === 'app') {
      result.fields = [{ field: 'current_version_release_date', object: 'app', order: 'desc' }].concat(defaultSorts);
    } else if (resultType === 'publisher') {
      result.fields = [
        {
          field: 'current_version_release_date',
          object: 'app',
          order: 'desc',
          function: 'max',
        },
      ];
    }
  } else if (resultType === 'app') {
    result.fields = formattedSorts.concat(defaultSorts);
  } else if (resultType === 'publisher') {
    result.fields = formattedSorts;
  }

  return result;
}

export const convertToQuerySort = (sorts, form) => _.compact(sorts.map((sort) => {
  const map = sortMap(form);

  if (map[sort.id]) {
    const result = {
      ...sortMap(form)[sort.id],
      order: sort.desc ? 'desc' : 'asc',
    };

    if (sort.id === headerNames.RANK) {
      result.order = sort.desc ? 'asc' : 'desc';
    } else if ([headerNames.MONTHLY_CHANGE, headerNames.WEEKLY_CHANGE, headerNames.ENTERED_CHART].includes(sort.id)) {
      result.function = sort.desc ? 'max' : 'min';
    }

    return result;
  }
  return null;
}));

export const sortMap = (form) => {
  const { resultType } = form;
  const sorts = {
    [headerNames.PUBLISHER]: { field: 'name', object: 'publisher' },
  };

  if (resultType === 'app') {
    return {
      ...sorts,
      [headerNames.APP]: { field: 'name', object: 'app' },
      [headerNames.DOWNLOADS]: { field: 'downloads_min', object: 'app' },
      [headerNames.ENTERED_CHART]: {
        field: 'created_at',
        object: 'newcomer',
        filter: {
          operator: 'union',
          inputs: [buildRankingsSort('newcomer', form)],
        },
      },
      [headerNames.FIRST_SEEN_ADS]: { field: 'first_seen_ads_date', object: 'mobile_ad_data_summary', function: 'min' },
      [headerNames.LAST_SEEN_ADS]: { field: 'last_seen_ads_date', object: 'mobile_ad_data_summary', function: 'max' },
      [headerNames.LAST_UPDATED]: { field: 'current_version_release_date', object: 'app' },
      [headerNames.MOBILE_PRIORITY]: { field: 'current_version_release_date', object: 'app' },
      [headerNames.MONTHLY_CHANGE]: {
        field: 'monthly_change',
        object: 'ranking',
        filter: {
          operator: 'intersect',
          inputs: [buildRankingsSort('default', form)],
        },
      },
      [headerNames.RANK]: {
        field: 'rank',
        object: 'ranking',
        function: 'min',
        filter: {
          operator: 'intersect',
          inputs: [buildRankingsSort('default', form)],
        },
      },
      [headerNames.RATING]: { field: 'all_version_rating', object: 'app' },
      [headerNames.RATINGS_COUNT]: { field: 'all_version_ratings_count', object: 'app' },
      [headerNames.RELEASE_DATE]: { field: 'original_release_date', object: 'app' },
      [headerNames.WEEKLY_CHANGE]: {
        field: 'weekly_change',
        object: 'ranking',
        filter: {
          operator: 'intersect',
          inputs: [buildRankingsSort('default', form)],
        },
      },
    };
  } else if (resultType === 'publisher') {
    return {
      ...sorts,
      [headerNames.DOWNLOADS]: { field: 'downloads_min', object: 'app', function: 'sum' },
      [headerNames.FIRST_SEEN_ADS]: { field: 'first_seen_ads_date', object: 'mobile_ad_data_summary' },
      [headerNames.LAST_SEEN_ADS]: { field: 'last_seen_ads_date', object: 'mobile_ad_data_summary' },
      [headerNames.LAST_UPDATED]: { field: 'current_version_release_date', object: 'app', function: 'max' },
      [headerNames.NUM_APPS]: { field: 'id', object: 'app', function: 'count' },
      [headerNames.RATING]: { field: 'average_rating', object: 'app' },
      [headerNames.RATINGS_COUNT]: { field: 'all_version_ratings_count', object: 'app', function: 'sum' },
    };
  }

  return null;
};

function buildRankingsSort (type, form) {
  const rankingsFilter = getNestedValue(['filters', 'rankings', 'value'], form);

  return buildRankingsFilters({
    platform: form.platform,
    filters: {
      rankings: {
        value: {
          countries: ['US', 'FR', 'CA', 'CN', 'BR', 'AU', 'UK', 'SP', 'IT', 'DE', 'SE', 'RU', 'KR', 'JP', 'CH', 'SG', 'NL'].join(','),
          charts: 'free',
          ...rankingsFilter,
          eventType: { value: type },
          values: [],
          dateRange: rankingsFilter ? rankingsFilter.dateRange : { value: 'two-week', label: 'Two Weeks' },
        },
      },
    },
  });
}

export const getSortName = (sort, resultType) => {
  const map = sortMap({ resultType });
  const { field, object } = sort;
  for (const key in map) {
    if (map[key]) {
      const mappedSort = map[key];
      if (mappedSort && mappedSort.field === field && mappedSort.object === object) {
        return key;
      }
    }
  }

  return null;
};
