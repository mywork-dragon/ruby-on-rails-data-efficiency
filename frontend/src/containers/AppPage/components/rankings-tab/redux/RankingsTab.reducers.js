import { $localStorage } from 'utils/localStorage.utils';
import { getNestedValue } from 'utils/format.utils';
import { RANKINGS_TAB_ACTION_TYPES, RANKINGS_CHART } from './RankingsTab.actions';

const defaultCountries = [
  { value: 'US', label: 'United States' },
  { value: 'CA', label: 'Canada' },
  // { value: 'AU', label: 'Australia' },
  // { value: 'CN', label: 'China' },
  { value: 'RU', label: 'Russia' },
  // { value: 'DE', label: 'Germany' },
  { value: 'FR', label: 'France' },
  { value: 'GB', label: 'United Kingdom' },
  // { value: 'JP', label: 'Japan' },
  // { value: 'KR', label: 'South Korea' },
  // { value: 'ES', label: 'Spain' },
];

const initialState = {
  id: '',
  platform: '',
  appIdentifier: '',
  selectedCountries: $localStorage.get('defaultRankingsCountries') || defaultCountries,
  selectedCategories: '',
  selectedRankingTypes: '',
  selectedDateRange: { value: 30, label: 'Last Month' },
  chartData: [],
  chartLoading: false,
  chartLoaded: false,
  error: false,
  errorMessage: null,
};

function rankingsTab(state = initialState, action) {
  switch (action.type) {
    case RANKINGS_TAB_ACTION_TYPES.UPDATE_APP_INFO:
      return {
        ...initialState,
        ...action.payload,
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
    case RANKINGS_CHART.REQUEST:
      return {
        ...state,
        chartLoading: true,
        chartLoaded: false,
      };
    case RANKINGS_CHART.SUCCESS:
      return {
        ...state,
        chartData: action.payload.data,
        chartLoading: false,
        chartLoaded: true,
      };
    case RANKINGS_CHART.FAILURE:
      return {
        ...state,
        chartData: [],
        chartLoaded: true,
        chartLoading: false,
        error: true,
        errorMessage: action.payload.message,
      };
    default:
      return state;
  }
}

export default rankingsTab;
