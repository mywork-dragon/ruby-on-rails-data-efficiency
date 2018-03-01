/* eslint-env jest */
/* eslint quote-props: 0 */

import { headerNames } from 'Table/redux/column.models';
import * as utils from '../../explore/general.utils';
import * as testData from './testData';
import { sampleQuery } from './sampleQuery';

describe('exploreUtils', () => {
  describe('formatResults', () => {
    it('should take in the response data and params and return an object of results formatted for the table reducer', () => {
      const expected = {
        results: [
          {
            'last_updated': '2017-12-01',
            'name': 'Taps to Riches',
            'publisher_name': 'Game Circus LLC',
            'platform': 'ios',
            'mobile_priority': 'high',
            'current_version': '2.17',
            'publisher_id': 131716,
            'id': 2729366,
            type: 'IosApp',
          },
        ],
        resultsCount: 1,
        resultType: 'app',
        pageSize: 20,
        pageNum: 2,
        sort: [{ id: headerNames.APP, desc: false }],
      };

      const results = utils.formatResults(testData.mockResultsResponse, sampleQuery, 1);

      expect(results).toEqual(expected);
    });
  });

  describe('getSortName', () => {
    it('should take in a select field and return the corresponding sort/display field', () => {
      expect(utils.getSortName('name')).toBe(headerNames.APP);
      expect(utils.getSortName('last_updated')).toBe(headerNames.LAST_UPDATED);
    });
  });

  describe('addItemType', () => {
    it('should take in an app and add its item type', () => {
      const app = testData.mockResultsResponse.pages[2][0];
      const expected = utils.addItemType(app);

      expect(expected.type).toEqual('IosApp');
    });
  });

  describe('convertToTableSort', () => {
    it('should take in a query sort and format it for the table component', () => {
      const sorts = sampleQuery.sort.fields;
      const expected = [{ id: headerNames.APP, desc: false }];
      const result = utils.convertToTableSort(sorts);

      expect(result).toEqual(expected);
    });
  });

  describe('panelFilterCount', () => {
    it('should take in the filters and a panelKey and return the number of filters belonging to the panel', () => {

      expect(utils.panelFilterCount(testData.form.filters, '1')).toEqual(1);
      expect(utils.panelFilterCount(testData.form.filters, '2')).toEqual(2);
      expect(utils.panelFilterCount(testData.form.filters, '3')).toEqual(1);
    });
  });
});
