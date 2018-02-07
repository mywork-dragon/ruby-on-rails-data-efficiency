import {
  createAdIntelTabActionTypes,
  createAdIntelTabRequestTypes,
  createAdIntelTabActions,
  createAdIntelTabRequestActions,
} from 'components/ad-intel-tab/redux/AdIntelTab.actions';

export const APP_AD_INTEL_ACTION_TYPES = createAdIntelTabActionTypes('appPage');
export const appAdIntelActions = createAdIntelTabActions(APP_AD_INTEL_ACTION_TYPES);

export const APP_AD_INTEL_REQUEST_TYPES = createAdIntelTabRequestTypes('appPage');
export const appAdIntelRequestActions = createAdIntelTabRequestActions(APP_AD_INTEL_REQUEST_TYPES);

export const AD_INTEL_TYPES = Object.assign({}, APP_AD_INTEL_ACTION_TYPES, APP_AD_INTEL_REQUEST_TYPES);
export const adIntelActions = Object.assign({}, appAdIntelActions, appAdIntelRequestActions);
