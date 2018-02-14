/* eslint-env jest */

import { headerNames } from 'Table/redux/column.models';
import * as utils from '../table.utils';

describe('Table Utils', () => {
  const headers = [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.MOBILE_PRIORITY,
    headerNames.FORTUNE_RANK
  ];
  const activeHeaders = [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.MOBILE_PRIORITY,
  ];
  const lockedHeaders = [headerNames.APP];
  const selectedItems = [];
  const allSelected = false;
  const toggleItem = jest.fn();
  const toggleAll = jest.fn();

  describe('initializeColumns', () => {
    it('should take in a list of columns return an object mapping each column to their display status, which should default to true', () => {
      const columns = utils.initializeColumns(headers);

      expect(columns[headerNames.APP]).toBe(true);
    });

    it('should take in a list of available columns and active columns and set each column\'s display status accordingly', () => {
      const columns = utils.initializeColumns(headers, activeHeaders);

      expect(columns[headerNames.APP]).toBe(true);
      expect(columns[headerNames.PUBLISHER]).toBe(true);
      expect(columns[headerNames.FORTUNE_RANK]).toBe(false);
    });

    it('can optionally accept a list of locked columns', () => {
      const columns = utils.initializeColumns(headers, activeHeaders, lockedHeaders);

      expect(columns[headerNames.APP]).toBe('LOCKED');
      expect(columns[headerNames.PUBLISHER]).toBe(true);
      expect(columns[headerNames.FORTUNE_RANK]).toBe(false);
    });
  });

  describe('generateColumns', () => {
    it('should generate a list of React Table formatted column models given a list of header names', () => {
      const mappedHeaders = utils.initializeColumns(headers);
      const columns = utils.generateColumns(mappedHeaders);

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
