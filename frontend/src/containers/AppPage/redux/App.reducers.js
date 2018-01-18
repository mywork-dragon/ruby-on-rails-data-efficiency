import { combineReducers } from 'redux';
import adIntelTab from 'components/ad-intel-tab/redux/AdIntelTab.reducers';
import { APP_AD_INTEL_ACTION_TYPES } from './App.actions';

const app = combineReducers({
  adIntelligence: adIntelTab(APP_AD_INTEL_ACTION_TYPES),
});

export default app;
