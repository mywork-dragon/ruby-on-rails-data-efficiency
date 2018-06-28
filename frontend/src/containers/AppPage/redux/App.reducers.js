import { combineReducers } from 'redux';
import adIntelTab from 'components/ad-intel-tab/redux/AdIntelTab.reducers';
import rankingsTab from '../components/rankings-tab/redux/RankingsTab.reducers';
import { AD_INTEL_TYPES } from './App.actions';

const appPage = combineReducers({
  adIntelligence: adIntelTab(AD_INTEL_TYPES),
  rankings: rankingsTab,
});

export default appPage;
