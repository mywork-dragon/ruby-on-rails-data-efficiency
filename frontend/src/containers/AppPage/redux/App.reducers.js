import { combineReducers } from 'redux';
import adIntelTab from 'components/ad-intel-tab/redux/AdIntelTab.reducers';
import { AD_INTEL_TYPES } from './App.actions';

const appPage = combineReducers({
  adIntelligence: adIntelTab(AD_INTEL_TYPES),
});

export default appPage;
