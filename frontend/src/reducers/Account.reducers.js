import { combineReducers } from 'redux';
import adNetworks from './AdNetworks.reducers';
import savedSearches from './SavedSearch.reducers';
import permissions from './Permissions.reducers.js';

const account = combineReducers({
  adNetworks,
  savedSearches,
  permissions,
});

export default account;
