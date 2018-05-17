import { combineReducers } from 'redux';
import {
  CATEGORIES,
  AVAILABLE_COUNTRIES,
  SDK_CATEGORIES,
  RANKINGS_COUNTRIES,
  APP_PERMISSIONS_OPTIONS,
  GEO_OPTIONS,
} from 'actions/AppStore.actions';

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
      return {
        ...initialCategoryState,
        ...action.payload.categories,
        loaded: true,
      };
    case CATEGORIES.FAILURE:
      return {
        ...state,
        fetching: false,
        loaded: true,
      };
    default:
      return state;
  }
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
    case AVAILABLE_COUNTRIES.FAILURE:
      return {
        ...state,
        loaded: true,
        fetching: false,
      };
    default:
      return state;
  }
}

const initialSdkCategoriesState = {
  loaded: false,
  fetching: false,
  iosCategoriesById: {},
  androidCategoriesById: {},
};

function sdkCategories (state = initialSdkCategoriesState, action) {
  switch (action.type) {
    case SDK_CATEGORIES.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case SDK_CATEGORIES.SUCCESS:
      return {
        ...initialCategoryState,
        ...action.payload.sdkCategories,
        loaded: true,
      };
    case SDK_CATEGORIES.FAILURE:
      return {
        ...state,
        fetching: false,
        loaded: true,
      };
    default:
      return state;
  }
}

const initialRankingsCountriesState = {
  loaded: false,
  fetching: false,
  rankingsCountries: [],
};

function rankingsCountries (state = initialRankingsCountriesState, action) {
  switch (action.type) {
    case RANKINGS_COUNTRIES.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case RANKINGS_COUNTRIES.SUCCESS:
      return {
        ...state,
        rankingsCountries: action.payload.countries,
        loaded: true,
        fetching: false,
      };
    case RANKINGS_COUNTRIES.FAILURE:
      return {
        ...state,
        loaded: true,
        fetching: false,
      };
    default:
      return state;
  }
}

const initialAppPermissionsOptionsState = {
  loaded: false,
  fetching: false,
  options: {},
};

function appPermissionsOptions (state = initialAppPermissionsOptionsState, action) {
  switch (action.type) {
    case APP_PERMISSIONS_OPTIONS.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case APP_PERMISSIONS_OPTIONS.SUCCESS:
      return {
        ...state,
        options: action.payload.countries,
        loaded: true,
        fetching: false,
      };
    case APP_PERMISSIONS_OPTIONS.FAILURE:
      return {
        ...state,
        loaded: true,
        fetching: false,
      };
    default:
      return state;
  }
}

const initialGeoOptionsState = {
  loaded: false,
  fetching: false,
  cities: {},
  states: {},
  countries: {},
};

function geoOptions (state = initialGeoOptionsState, action) {
  switch (action.type) {
    case GEO_OPTIONS.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case GEO_OPTIONS.SUCCESS:
      return {
        ...state,
        ...action.payload.headquarters,
        loaded: true,
        fetching: false,
      };
    case GEO_OPTIONS.FAILURE:
      return {
        ...state,
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
  sdkCategories,
  rankingsCountries,
  appPermissionsOptions,
  geoOptions,
});

export default appStoreInfo;
