import { action, namespaceActions, createRequestTypes } from 'utils/action.utils';

const actionTypes = [
  'UPDATE_APP_INFO',
  'UPDATE_COUNTRIES_FILTER',
  'UPDATE_CATEGORIES_FILTER',
  'UPDATE_RANKING_TYPES_FILTER',
  'UPDATE_DATE_RANGE',
];

export const RANKINGS_TAB_ACTION_TYPES = namespaceActions('rankingsTab', actionTypes);

export const RANKINGS_CHART_REQUEST_TYPES = createRequestTypes('rankingsTab/RANKINGS_CHART');

export const rankingsChart = {
  request: () => action(RANKINGS_CHART_REQUEST_TYPES.REQUEST),
  success: data => action(RANKINGS_CHART_REQUEST_TYPES.SUCCESS, { data }),
  failure: error => action(RANKINGS_CHART_REQUEST_TYPES.FAILURE, { error }),
};

export const updateAppInfo = (id, platform, appIdentifier) => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_APP_INFO, { id, platform, appIdentifier });

export const updateCountriesFilter = countries => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER, { countries });

export const updateCategoriesFilter = categories => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_CATEGORIES_FILTER, { categories });

export const updateRankingTypesFilter = types => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_RANKING_TYPES_FILTER, { types });

export const updateDateRange = value => action(RANKINGS_TAB_ACTION_TYPES.UPDATE_DATE_RANGE, { value });
