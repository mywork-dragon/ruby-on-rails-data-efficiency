import { action, namespaceActions, buildBaseRequestTypes } from 'utils/action.utils';

const adIntelTabActionTypes = [
  'CLEAR_AD_INTEL_INFO',
  'UPDATE_ACTIVE_CREATIVE_INDEX',
  'TOGGLE_CREATIVE_FILTER',
];

const adIntelTabRequestActionTypes = [
  'AD_INTEL_INFO',
  'CREATIVES',
];

export const createAdIntelTabActionTypes = base => namespaceActions(base, adIntelTabActionTypes);
export const createAdIntelTabRequestTypes = base => buildBaseRequestTypes(base, adIntelTabRequestActionTypes);

export function createAdIntelTabActions (types) {
  return {
    updateActiveCreativeIndex: index => action(types.UPDATE_ACTIVE_CREATIVE_INDEX, { index }),
    toggleCreativeFilter: (value, type) => action(types.TOGGLE_CREATIVE_FILTER, { value, type }),
  };
}

export function createAdIntelTabRequestActions (types) {
  return {
    adIntelInfo: {
      request: (id, platform) => action(types.AD_INTEL_INFO.REQUEST, { id, platform }),
      success: (id, platform, data) => action(types.AD_INTEL_INFO.SUCCESS, { id, platform, data }),
      failure: (id, platform) => action(types.AD_INTEL_INFO.FAILURE, { id, platform }),
    },
    creatives: {
      request: (id, platform, params) => action(types.CREATIVES.REQUEST, { id, platform, params }),
      success: (id, data) => action(types.CREATIVES.SUCCESS, { id, data }),
    },
  };
}
