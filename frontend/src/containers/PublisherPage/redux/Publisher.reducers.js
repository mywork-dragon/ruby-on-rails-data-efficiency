import { combineReducers } from 'redux';
import adIntelTab from 'components/ad-intel-tab/redux/AdIntelTab.reducers';
import { PUBLISHER_AD_INTEL_ACTION_TYPES, PUB_AD_INTEL_TABLE_ACTION_TYPES } from './Publisher.actions';

const publisher = combineReducers({
  adIntelligence: adIntelTab(PUBLISHER_AD_INTEL_ACTION_TYPES, PUB_AD_INTEL_TABLE_ACTION_TYPES),
});

export default publisher;
