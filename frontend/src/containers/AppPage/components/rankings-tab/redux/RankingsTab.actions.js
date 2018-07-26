import { action, namespaceActions, createRequestTypes } from 'utils/action.utils';

const actionTypes = [
  'UPDATE_APP_INFO',
  'UPDATE_COUNTRIES_FILTER',
  'UPDATE_CATEGORIES_FILTER',
  'UPDATE_RANKING_TYPES_FILTER',
  'UPDATE_DATE_RANGE',
  'UPDATE_TABLE_SORT',
];

export const RANKINGS_TAB_ACTION_TYPES = namespaceActions('rankingsTab', actionTypes);

export const RANKINGS_CHART = createRequestTypes('rankingsTab/RANKINGS_CHART');

export const rankingsChart = {
  request: () => action(RANKINGS_CHART.REQUEST),
  success: data => action(RANKINGS_CHART.SUCCESS, { data }),
  failure: message => action(RANKINGS_CHART.FAILURE, { message }),
};

export const updateAppInfo = (id, platform, appIdentifier) => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_APP_INFO, { id, platform, appIdentifier });

export const updateCountriesFilter = countries => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER, { countries });

export const updateCategoriesFilter = categories => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_CATEGORIES_FILTER, { categories });

export const updateRankingTypesFilter = types => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_RANKING_TYPES_FILTER, { types });

export const updateDateRange = value => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_DATE_RANGE, { value });

export const updateTableSort = (field, order) => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_TABLE_SORT, { field, order });
