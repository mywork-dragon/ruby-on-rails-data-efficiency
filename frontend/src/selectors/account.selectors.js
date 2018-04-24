import _ from 'lodash';

export const getSearches = state => _.orderBy(Object.values(state.account.savedSearches.searches), ['created_at'], ['desc']);

export const getSavedSearchById = (state, id) => state.account.savedSearches.searches[id];

export const needSavedSearches = state => !state.account.savedSearches.loaded && !state.account.savedSearches.fetching;

export const shouldFetchAdNetworks = state => !state.account.adNetworks.loaded && !state.account.adNetworks.fetching;

export const accessibleNetworks = state => Object.values(state.account.adNetworks.adNetworks).filter(x => x.can_access);

export const isFacebookOnly = state => accessibleNetworks(state).length === 1 && accessibleNetworks(state)[0].id === 'facebook';

export const needPermissions = state => !state.account.permissions.loaded && !state.account.permissions.fetching;

export const getPermissions = state => state.account.permissions.permissions;
