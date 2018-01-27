/* eslint-env jest */

import * as actions from './Table.actions';

describe('Table Actions', () => {
  const actionTypes = actions.createTableActionTypes('publisher/adIntelligence');
  const results = actions.createTableActions(actionTypes);

  describe('createTableActionTypes', () => {
    it('should return an object containing all table action types namespaced within the provided key', () => {
      expect(actionTypes.LOAD_RESULTS).toBe('publisher/adIntelligence/LOAD_RESULTS');
      expect(actionTypes.TOGGLE_ITEM).toBe('publisher/adIntelligence/TOGGLE_ITEM');
      expect(actionTypes.TOGGLE_ALL_ITEMS).toBe('publisher/adIntelligence/TOGGLE_ALL_ITEMS');
    });
  });

  describe('createTableActions', () => {
    it('should return an object containing all table actions', () => {
      const items = [];
      const item = { id: '56', type: 'AndroidApp' };

      expect(results.loadResults(items)).toEqual({ type: actionTypes.LOAD_RESULTS, payload: { results: items } });
      expect(results.toggleItem(item)).toEqual({ type: actionTypes.TOGGLE_ITEM, payload: { item } });
      expect(results.toggleAllItems()).toEqual({ type: actionTypes.TOGGLE_ALL_ITEMS });
    });
  });
});
