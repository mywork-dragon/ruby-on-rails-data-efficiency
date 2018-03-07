import { action, createRequestTypes } from 'utils/action.utils';

export const CATEGORIES = createRequestTypes('CATEGORIES');
export const categories = {
  request: () => action(CATEGORIES.REQUEST),
  success: data => action(CATEGORIES.SUCCESS, { categories: data }),
  failure: () => action(CATEGORIES.FAILURE),
};

export const AVAILABLE_COUNTRIES = createRequestTypes('AVAILABLE_COUNTRIES');
export const availableCountries = {
  request: () => action(AVAILABLE_COUNTRIES.REQUEST),
  success: countries => action(AVAILABLE_COUNTRIES.SUCCESS, { countries }),
  failure: () => action(AVAILABLE_COUNTRIES.FAILURE),
};
