/* eslint-env jest */

import * as utils from './AdIntelTab.actions';

describe('Ad Intel Tab Actions', () => {
  const actionTypes = utils.createAdIntelTabActionTypes('app');
  const requestTypes = utils.createAdIntelTabRequestTypes('app');
  const actions = utils.createAdIntelTabActions(actionTypes);
  const requestActions = utils.createAdIntelTabRequestActions(requestTypes);

  describe('createAdIntelTabActionTypes', () => {
    it('should return an object containing all ad intel tab action types namespaced within the provided key', () => {
      expect(actionTypes.CLEAR_AD_INTEL_INFO).toBe('app/CLEAR_AD_INTEL_INFO');
      expect(requestTypes.AD_INTEL_INFO.FAILURE).toBe('app/AD_INTEL_INFO_FAILURE');
      expect(actionTypes.TOGGLE_CREATIVE_FILTER).toBe('app/TOGGLE_CREATIVE_FILTER');
    });
  });

  describe('createAdIntelTabActions', () => {
    it('should return an object containing all ad intel tab actions', () => {
      expect(requestActions.adIntelInfo.request(1, 'ios')).toEqual({ type: requestTypes.AD_INTEL_INFO.REQUEST, payload: { id: 1, platform: 'ios' } });
      expect(requestActions.adIntelInfo.failure(34, 'android')).toEqual({ type: requestTypes.AD_INTEL_INFO.FAILURE, payload: { id: 34, platform: 'android' } });
      expect(actions.updateActiveCreativeIndex(5)).toEqual({ type: actionTypes.UPDATE_ACTIVE_CREATIVE_INDEX, payload: { index: 5 } });
    });
  });
});
