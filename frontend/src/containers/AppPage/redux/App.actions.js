import { createAdIntelTabActionTypes, createAdIntelTabActions } from 'components/ad-intel-tab/redux/AdIntelTab.actions';

export const APP_AD_INTEL_ACTION_TYPES = createAdIntelTabActionTypes('app');
export const appAdIntelActions = createAdIntelTabActions(APP_AD_INTEL_ACTION_TYPES);
