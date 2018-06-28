import { rankingsTabActionTypes } from './RankingsTab.actions';

const initialState = {
  id: '',
  selectedCountries: '',
  selectedCategories: '',
  selectedRankingTypes: '',
};

function rankingsTab(state = initialState, action) {
  switch (action.type) {
    case rankingsTabActionTypes.UPDATE_ID:
      return {
        ...state,
        id: action.payload.id,
        selectedCountries: '',
        selectedCategories: '',
        selectedRankingTypes: '',
      };
    case rankingsTabActionTypes.UPDATE_COUNTRIES_FILTER:
      return {
        ...state,
        selectedCountries: action.payload.countries,
      };
    case rankingsTabActionTypes.UPDATE_CATEGORIES_FILTER:
      return {
        ...state,
        selectedCategories: action.payload.categories,
      };
    case rankingsTabActionTypes.UPDATE_RANKING_TYPES_FILTER:
      return {
        ...state,
        selectedRankingTypes: action.payload.types,
      };
    default:
      return state;
  }
}

export default rankingsTab;
