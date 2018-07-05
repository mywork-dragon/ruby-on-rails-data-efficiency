import { rankingsTabActionTypes } from './RankingsTab.actions';

const defaultCountries = [
  { value: 'US', label: 'United States' },
  { value: 'CA', label: 'Canada' },
  { value: 'AU', label: 'Australia' },
  { value: 'CN', label: 'China' },
  { value: 'RU', label: 'Russia' },
  { value: 'DE', label: 'Germany' },
  { value: 'FR', label: 'France' },
  { value: 'GB', label: 'United Kingdom' },
  { value: 'JP', label: 'Japan' },
  { value: 'KR', label: 'South Korea' },
  { value: 'ES', label: 'Spain' },
];

const initialState = {
  id: '',
  selectedCountries: defaultCountries,
  selectedCategories: '',
  selectedRankingTypes: '',
};

function rankingsTab(state = initialState, action) {
  switch (action.type) {
    case rankingsTabActionTypes.UPDATE_ID:
      return {
        ...state,
        id: action.payload.id,
        selectedCountries: defaultCountries,
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
