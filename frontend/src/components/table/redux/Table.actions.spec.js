/* eslint-env jest */

import * as utils from './Table.actions';

describe('Table Actions', () => {
  const actionTypes = utils.createTableActionTypes('publisher/adIntelligence');
  const requestTypes = utils.createTableRequestTypes('publisher/adIntelligence');
  const actions = utils.createTableActions(actionTypes);
  const requestActions = utils.createTableRequestActions(requestTypes);

  describe('createTableActionTypes', () => {
    it('should return an object containing all table action types namespaced within the provided key', () => {
      expect(requestTypes.ALL_ITEMS.SUCCESS).toBe('publisher/adIntelligence/ALL_ITEMS_SUCCESS');
      expect(actionTypes.TOGGLE_ITEM).toBe('publisher/adIntelligence/TOGGLE_ITEM');
      expect(actionTypes.TOGGLE_ALL_ITEMS).toBe('publisher/adIntelligence/TOGGLE_ALL_ITEMS');
    });
  });

  describe('createTableActions', () => {
    it('should return an object containing all table actions', () => {
      const items = [];
      const item = { id: '56', type: 'AndroidApp' };

      expect(requestActions.allItems.success(items)).toEqual({ type: requestTypes.ALL_ITEMS.SUCCESS, payload: { data: items } });
      expect(actions.toggleItem(item)).toEqual({ type: actionTypes.TOGGLE_ITEM, payload: { item } });
      expect(actions.toggleAllItems()).toEqual({ type: actionTypes.TOGGLE_ALL_ITEMS });
    });
  });
});
