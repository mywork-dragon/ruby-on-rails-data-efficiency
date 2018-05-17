import { action, createRequestTypes } from 'utils/action.utils';

export const CATEGORIES = createRequestTypes('CATEGORIES');
export const categories = {
  request: () => action(CATEGORIES.REQUEST),
  success: data => action(CATEGORIES.SUCCESS, { categories: data }),
  failure: error => action(CATEGORIES.FAILURE, { error }),
};

export const AVAILABLE_COUNTRIES = createRequestTypes('AVAILABLE_COUNTRIES');
export const availableCountries = {
  request: () => action(AVAILABLE_COUNTRIES.REQUEST),
  success: countries => action(AVAILABLE_COUNTRIES.SUCCESS, { countries }),
  failure: error => action(AVAILABLE_COUNTRIES.FAILURE, { error }),
};

export const SDK_CATEGORIES = createRequestTypes('SDK_CATEGORIES');
export const sdkCategories = {
  request: () => action(SDK_CATEGORIES.REQUEST),
  success: data => action(SDK_CATEGORIES.SUCCESS, { sdkCategories: data }),
  failure: error => action(SDK_CATEGORIES.FAILURE, { error }),
};

export const RANKINGS_COUNTRIES = createRequestTypes('RANKINGS_COUNTRIES');
export const rankingsCountries = {
  request: () => action(RANKINGS_COUNTRIES.REQUEST),
  success: countries => action(RANKINGS_COUNTRIES.SUCCESS, { countries }),
  failure: error => action(RANKINGS_COUNTRIES.FAILURE, { error }),
};

export const APP_PERMISSIONS_OPTIONS = createRequestTypes('APP_PERMISSIONS_OPTIONS');
export const appPermissionsOptions = {
  request: () => action(APP_PERMISSIONS_OPTIONS.REQUEST),
  success: countries => action(APP_PERMISSIONS_OPTIONS.SUCCESS, { countries }),
  failure: error => action(APP_PERMISSIONS_OPTIONS.FAILURE, { error }),
};

export const GEO_OPTIONS = createRequestTypes('GEO_OPTIONS');
export const geoOptions = {
  request: () => action(GEO_OPTIONS.REQUEST),
  success: headquarters => action(GEO_OPTIONS.SUCCESS, { headquarters }),
  failure: error => action(GEO_OPTIONS.FAILURE, { error }),
};
