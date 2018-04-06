import { action, createRequestTypes } from 'utils/action.utils';

export const AD_NETWORKS = createRequestTypes('AD_NETWORKS');
export const adNetworks = {
  request: () => action(AD_NETWORKS.REQUEST),
  success: networks => action(AD_NETWORKS.SUCCESS, { networks }),
  failure: error => action(AD_NETWORKS.FAILURE, { error }),
};

export const GET_SAVED_SEARCHES = createRequestTypes('GET_SAVED_SEARCHES');
export const getSavedSearches = {
  request: () => action(GET_SAVED_SEARCHES.REQUEST),
  success: searches => action(GET_SAVED_SEARCHES.SUCCESS, { searches }),
  failure: error => action(GET_SAVED_SEARCHES.FAILURE, { error }),
};

export const SAVE_NEW_SEARCH = createRequestTypes('SAVE_NEW_SEARCH');
export const saveNewSearch = {
  request: (name, params) => action(SAVE_NEW_SEARCH.REQUEST, { name, params }),
  success: search => action(SAVE_NEW_SEARCH.SUCCESS, { search }),
  failure: error => action(SAVE_NEW_SEARCH.FAILURE, { error }),
};

export const LOAD_SAVED_SEARCH = createRequestTypes('LOAD_SAVED_SEARCH');
export const loadSavedSearch = {
  request: (searchId, id) => action(LOAD_SAVED_SEARCH.REQUEST, { searchId, id }),
  success: id => action(LOAD_SAVED_SEARCH.SUCCESS, { id }),
  failure: error => action(LOAD_SAVED_SEARCH.FAILURE, { error }),
};

export const DELETE_SAVED_SEARCH = createRequestTypes('DELETE_SAVED_SEARCH');
export const deleteSavedSearch = {
  request: id => action(DELETE_SAVED_SEARCH.REQUEST, { id }),
  success: id => action(DELETE_SAVED_SEARCH.SUCCESS, { id }),
  failure: error => action(DELETE_SAVED_SEARCH.FAILURE, { error }),
};

export const LOAD_PERMISSIONS = createRequestTypes('LOAD_PERMISSIONS');
export const loadPermissions = {
  request: () => action(LOAD_PERMISSIONS.REQUEST),
  success: (data) => action(LOAD_PERMISSIONS.SUCCESS, { data }),
  failure: error => action(LOAD_PERMISSIONS.FAILURE, { error }),
};
