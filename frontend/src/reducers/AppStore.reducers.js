import { combineReducers } from 'redux';
import { CATEGORIES, AVAILABLE_COUNTRIES } from 'actions/AppStore.actions';

const initialCategoryState = {
  loaded: false,
  fetching: false,
  iosCategoriesById: {},
  androidCategoriesById: {},
};

function categories(state = initialCategoryState, action) {
  switch (action.type) {
    case CATEGORIES.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case CATEGORIES.SUCCESS:
      return loadCategories(action);
    default:
      return state;
  }
}

function loadCategories(action) {
  return {
    ...initialCategoryState,
    ...action.payload.categories,
    loaded: true,
  };
}

const initialAvailableCountriesState = {
  loaded: false,
  fetching: false,
  availableCountries: [],
};

function availableCountries (state = initialAvailableCountriesState, action) {
  switch (action.type) {
    case AVAILABLE_COUNTRIES.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case AVAILABLE_COUNTRIES.SUCCESS:
      return {
        ...state,
        availableCountries: action.payload.countries,
        loaded: true,
        fetching: false,
      };
    default:
      return state;
  }
}

const appStoreInfo = combineReducers({
  categories,
  availableCountries,
});

export default appStoreInfo;
