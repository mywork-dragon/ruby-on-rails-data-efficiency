import { RANKINGS_TAB_ACTION_TYPES, RANKINGS_CHART_REQUEST_TYPES } from './RankingsTab.actions';

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
  selectedDateRange: { value: 7, label: 'Last Week' },
  chartData: [],
  chartLoading: false,
};

function rankingsTab(state = initialState, action) {
  switch (action.type) {
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_ID:
      return {
        ...initialState,
        id: action.payload.id,
      };
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER:
      return {
        ...state,
        selectedCountries: action.payload.countries,
      };
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_CATEGORIES_FILTER:
      return {
        ...state,
        selectedCategories: action.payload.categories,
      };
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_RANKING_TYPES_FILTER:
      return {
        ...state,
        selectedRankingTypes: action.payload.types,
      };
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_DATE_RANGE:
      return {
        ...state,
        selectedDateRange: action.payload.value,
      };
    case RANKINGS_CHART_REQUEST_TYPES.REQUEST:
      return {
        ...state,
        chartLoading: true,
      };
    case RANKINGS_CHART_REQUEST_TYPES.SUCCESS:
      return {
        ...state,
        chartData: action.payload.data,
        chartLoading: false,
      };
    default:
      return state;
  }
}

export default rankingsTab;
