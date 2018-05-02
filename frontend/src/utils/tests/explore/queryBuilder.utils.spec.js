/* eslint-env jest */
/* eslint camelcase: 0, quote-props: 0 */

import * as utils from '../../explore/queryBuilder.utils';
import { sampleQuery } from './sampleQuery';
import * as testData from './testData';

describe('buildExploreRequest', () => {
  describe('buildPageSettings', () => {
    it('should take an object containing page settings and return a query formatted object containing page settings', () => {
      const page_settings = utils.buildPageSettings(testData.pageSettings);

      expect(page_settings.page_size).toBe(testData.pageSettings.pageSize);
      expect(page_settings.page).toBe(testData.pageSettings.pageNum);
    });
  });

  describe('buildSortSettings', () => {
    describe('convertToQuerySort', () => {
      it('should take in the table sort and convert it to a query sort', () => {
        const expected = [{
          field: 'name',
          object: 'app',
          order: 'asc',
        }];

        const result = utils.convertToQuerySort(testData.sort, 'app');

        expect(result).toEqual(expected);
      });
    });

    it('should take a list of sorts and return sort settings for the query', () => {
      const sort_settings = utils.buildSortSettings(testData.sort, 'app');

      expect(Array.isArray(sort_settings.fields)).toBe(true);
      expect(sort_settings.fields[0]).toMatchObject(sampleQuery.sort.fields[0]);
    });
  });

  describe('buildSelect', () => {
    it('should take in a result type and map of columns and return an object containing the select parameters for the query', () => {
      const select = utils.buildSelect(testData.form, testData.columns, testData.accountNetworks);

      expect(select).toMatchObject(sampleQuery.select);
    });
  });

  describe('buildExploreRequest', () => {
    it('should take in the search form, the columns, the page settings, and the sort and return a formatted query', () => {
      const query = utils.buildExploreRequest(testData.form, testData.columns, testData.pageSettings, testData.sort, testData.accountNetworks);

      expect(query).toMatchObject(sampleQuery);
      expect(query.page_settings.page).toBe(1);
    });
  });
});
