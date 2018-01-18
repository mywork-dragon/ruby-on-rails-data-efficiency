/* eslint-env jest */

import * as actions from './AdIntelTab.actions';

describe('Ad Intel Tab Actions', () => {
  const actionTypes = actions.createAdIntelTabActionTypes('app');
  const results = actions.createAdIntelTabActions(actionTypes);

  describe('createAdIntelTabActionTypes', () => {
    it('should return an object containing all ad intel tab action types namespaced within the provided key', () => {
      expect(actionTypes.CLEAR_AD_INTEL_INFO).toBe('app/CLEAR_AD_INTEL_INFO');
      expect(actionTypes.AD_INTEL_INFO_FAILURE).toBe('app/AD_INTEL_INFO_FAILURE');
      expect(actionTypes.TOGGLE_CREATIVE_FILTER).toBe('app/TOGGLE_CREATIVE_FILTER');
    });
  });

  describe('createAdIntelTabActions', () => {
    it('should return an object containing all ad intel tab actions', () => {
      expect(results.requestAdIntelInfo(1, 'ios')).toEqual({ type: actionTypes.AD_INTEL_INFO_REQUEST, payload: { id: 1, platform: 'ios' } });
      expect(results.adIntelError(34, 'android')).toEqual({ type: actionTypes.AD_INTEL_INFO_FAILURE, payload: { id: 34, platform: 'android' } });
      expect(results.updateActiveCreativeIndex(5)).toEqual({ type: actionTypes.UPDATE_ACTIVE_CREATIVE_INDEX, payload: { index: 5 } });
    });
  });
});
