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
