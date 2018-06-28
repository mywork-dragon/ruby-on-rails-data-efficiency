import { action, namespaceActions } from 'utils/action.utils';

const actionTypes = [
  'UPDATE_ID',
  'UPDATE_COUNTRIES_FILTER',
  'UPDATE_CATEGORIES_FILTER',
  'UPDATE_RANKING_TYPES_FILTER',
];

export const rankingsTabActionTypes = namespaceActions('rankingsTab', actionTypes);

export const updateId = id => action(rankingsTabActionTypes.UPDATE_ID, { id });
export const updateCountriesFilter = countries => action(rankingsTabActionTypes.UPDATE_COUNTRIES_FILTER, { countries });
export const updateCategoriesFilter = categories => action(rankingsTabActionTypes.UPDATE_CATEGORIES_FILTER, { categories });
export const updateRankingTypesFilter = types => action(rankingsTabActionTypes.UPDATE_RANKING_TYPES_FILTER, { types });
