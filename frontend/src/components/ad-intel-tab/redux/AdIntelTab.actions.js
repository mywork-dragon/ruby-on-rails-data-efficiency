import { action, createRequestTypes, namespaceActions } from 'utils/action.utils';

const infoRequestTypes = createRequestTypes('AD_INTEL_INFO');
const creativesRequestTypes = createRequestTypes('CREATIVES');

const adIntelTabActionTypes = [
  'CLEAR_AD_INTEL_INFO',
  'UPDATE_ACTIVE_CREATIVE_INDEX',
  'TOGGLE_CREATIVE_FILTER',
].concat(infoRequestTypes, creativesRequestTypes);

export const createAdIntelTabActionTypes = base => namespaceActions(base, adIntelTabActionTypes);

export function createAdIntelTabActions (types) {
  return {
    requestAdIntelInfo: (id, platform) => action(types.AD_INTEL_INFO_REQUEST, { id, platform }),
    loadAdIntelInfo: (id, platform, data) => action(types.AD_INTEL_INFO_SUCCESS, { id, platform, data }),
    adIntelError: (id, platform) => action(types.AD_INTEL_INFO_FAILURE, { id, platform }),
    requestCreatives: (id, platform, params) => action(types.CREATIVES_REQUEST, { id, platform, params }),
    loadCreatives: (id, data) => action(types.CREATIVES_SUCCESS, { id, data }),
    updateActiveCreativeIndex: index => action(types.UPDATE_ACTIVE_CREATIVE_INDEX, { index }),
    toggleCreativeFilter: (value, type) => action(types.TOGGLE_CREATIVE_FILTER, { value, type }),
  };
}
