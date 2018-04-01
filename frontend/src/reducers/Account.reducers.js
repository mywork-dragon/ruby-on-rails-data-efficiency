import { combineReducers } from 'redux';
import adNetworks from './AdNetworks.reducers';
import savedSearches from './SavedSearch.reducers';

const account = combineReducers({
  adNetworks,
  savedSearches,
});

export default account;
