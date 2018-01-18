/* eslint-env jest */

import * as actions from './AppTable.actions';

describe('App Table Actions', () => {
  const actionTypes = actions.createAppTableActionTypes('publisher/adIntelligence');
  const results = actions.createAppTableActions(actionTypes);

  describe('createAppTableActionTypes', () => {
    it('should return an object containing all app table action types namespaced within the provided key', () => {
      expect(actionTypes.LOAD_APPS).toBe('publisher/adIntelligence/LOAD_APPS');
      expect(actionTypes.TOGGLE_ITEM).toBe('publisher/adIntelligence/TOGGLE_ITEM');
      expect(actionTypes.TOGGLE_ALL_ITEMS).toBe('publisher/adIntelligence/TOGGLE_ALL_ITEMS');
    });
  });

  describe('createAppTableActions', () => {
    it('should return an object containing all app table actions', () => {
      const apps = [];
      const app = { id: '56', type: 'AndroidApp' };

      expect(results.loadApps(apps)).toEqual({ type: actionTypes.LOAD_APPS, payload: { apps } });
      expect(results.toggleItem(app)).toEqual({ type: actionTypes.TOGGLE_ITEM, payload: { item: app } });
      expect(results.toggleAllItems()).toEqual({ type: actionTypes.TOGGLE_ALL_ITEMS });
    });
  });
});
