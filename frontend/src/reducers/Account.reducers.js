import { combineReducers } from 'redux';
import adNetworks from './AdNetworks.reducers';

const account = combineReducers({
  adNetworks,
});

export default account;
