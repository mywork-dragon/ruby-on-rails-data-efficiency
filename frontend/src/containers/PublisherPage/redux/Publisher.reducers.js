import { combineReducers } from 'redux';
import adIntelTab from 'components/ad-intel-tab/redux/AdIntelTab.reducers';
import { AD_INTEL_TYPES, TABLE_TYPES } from './Publisher.actions';

const publisherPage = combineReducers({
  adIntelligence: adIntelTab(AD_INTEL_TYPES, TABLE_TYPES),
});

export default publisherPage;
