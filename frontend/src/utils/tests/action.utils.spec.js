/* eslint-env jest */

import * as utils from '../action.utils';

describe('Action Utils', () => {
  describe('action', () => {
    it('should take an action type and payload and return a redux action', () => {
      expect(utils.action('LISTS_REQUEST')).toEqual({ type: 'LISTS_REQUEST' });
      expect(utils.action('APP_INFO_REQUEST', { id: 1, platform: 'ios' })).toEqual({ type: 'APP_INFO_REQUEST', payload: { id: 1, platform: 'ios' } });
    });
  });

  describe('createRequestTypes', () => {
    it('should return an object mapping request action types to their request type', () => {
      const base = 'APP_INFO';
      const requestTypes = utils.createRequestTypes(base);

      expect(requestTypes.REQUEST).toEqual('APP_INFO_REQUEST');
      expect(requestTypes.SUCCESS).toEqual('APP_INFO_SUCCESS');
      expect(requestTypes.FAILURE).toEqual('APP_INFO_FAILURE');
    });
  });

  describe('buildBaseRequestTypes', () => {
    it('should return an object nesting request action types within their action type', () => {
      const base = 'explore';
      const actionTypes = [
        'ALL_ITEMS',
      ];
      const requestActionTypes = utils.buildBaseRequestTypes(base, actionTypes);

      expect(requestActionTypes.ALL_ITEMS.REQUEST).toEqual('explore/ALL_ITEMS_REQUEST');
      expect(requestActionTypes.ALL_ITEMS.SUCCESS).toEqual('explore/ALL_ITEMS_SUCCESS');
      expect(requestActionTypes.ALL_ITEMS.FAILURE).toEqual('explore/ALL_ITEMS_FAILURE');
    });
  });

  describe('namespaceActions', () => {
    it('should return an object containing namespaced actions', () => {
      const base = 'explore/appTable';
      const actionTypes = ['TOGGLE_ITEM', 'TOGGLE_ALL_ITEMS', 'ADD_SELECTED_TO_LIST'];
      const types = utils.namespaceActions(base, actionTypes);

      expect(types.TOGGLE_ITEM).toEqual('explore/appTable/TOGGLE_ITEM');
      expect(types.TOGGLE_ALL_ITEMS).toEqual('explore/appTable/TOGGLE_ALL_ITEMS');
      expect(types.ADD_SELECTED_TO_LIST).toEqual('explore/appTable/ADD_SELECTED_TO_LIST');
    });
  });
});
