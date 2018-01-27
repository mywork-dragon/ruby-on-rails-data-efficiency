/* eslint-env jest */

import { headerNames } from 'Table/redux/column.models';
import * as utils from '../table.utils';

describe('Table Utils', () => {
  const headers = [headerNames.APP, headerNames.PUBLISHER, headerNames.MOBILE_PRIORITY];
  const selectedItems = [];
  const allSelected = false;
  const toggleItem = jest.fn();
  const toggleAll = jest.fn();

  describe('generateColumns', () => {
    it('should generate a list of React Table formatted column models given a list of header names', () => {
      const columns = utils.generateColumns(headers);

      expect(Array.isArray(columns)).toBe(true);
      expect(columns[0].id).toBe(headerNames.APP);
      expect(columns[2].id).toBe(headerNames.MOBILE_PRIORITY);
      expect(typeof columns[2].Cell).toBe('function');
    });

    it('should add a checkbox to the beginning of the list if given toggle options', () => {
      const columns = utils.generateColumns(headers, selectedItems, allSelected, toggleItem, toggleAll);

      expect(columns[0].className).toBe('checkbox-cell');
      expect(typeof columns[0].Cell).toBe('function');
    });
  });
});
