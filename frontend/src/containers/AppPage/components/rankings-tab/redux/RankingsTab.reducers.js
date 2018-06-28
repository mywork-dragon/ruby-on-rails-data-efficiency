import { rankingsTabActionTypes } from './RankingsTab.actions';

const initialState = {
  id: '',
  selectedCountries: '',
  selectedCategories: '',
};

function rankingsTab(state = initialState, action) {
  switch (action.type) {
    case rankingsTabActionTypes.UPDATE_ID:
      return {
        ...state,
        id: action.payload.id,
        selectedCountries: '',
        selectedCategories: '',
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
    default:
      return state;
  }
}

export default rankingsTab;
