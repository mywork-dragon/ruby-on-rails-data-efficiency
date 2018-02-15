/* eslint-env jest */
/* eslint camelcase: 0, quote-props: 0 */

import { headerNames } from 'Table/redux/column.models';
import * as utils from '../explore/queryBuilder.utils';
import { initializeColumns } from '../table.utils';
import { formatResults, extractPublisher } from '../explore/explore.utils';

const pageSettings = {
  pageSize: 20,
  pageNum: 1,
};
const form = {
  resultType: 'app',
  platform: 'all',
  includeTakenDown: false,
  filters: {},
};
const columns = initializeColumns([
  headerNames.APP,
  headerNames.PUBLISHER,
  headerNames.MOBILE_PRIORITY,
  headerNames.PLATFORM,
  headerNames.LAST_UPDATED,
]);

describe('buildExploreRequest', () => {
  describe('buildPageSettings', () => {
    it('should take an object containing page settings and return a query formatted object containing page settings', () => {
      const page_settings = utils.buildPageSettings(pageSettings);

      expect(page_settings.page_size).toBe(pageSettings.pageSize);
      expect(page_settings.page).toBe(pageSettings.pageNum + 1);
    });
  });

  describe('buildSelect', () => {
    it('should take in a result type and map of columns and return an object containing the select parameters for the query', () => {
      const select = utils.buildSelect(form.resultType, columns);

      expect(select).toMatchObject(utils.sampleQuery.select);
    });
  });

  // TODO: update once query language and library are finalized
  describe('buildQuery', () => {
    it('should take in the search form filters and return a query object', () => {
      const query = utils.buildQuery(form.filters);

      expect(query).toMatchObject(utils.sampleQuery.query);
    });
  });

  describe('buildExploreRequest', () => {
    it('should take in the search form, the columns, the page settings, and the sort and return a formatted query', () => {
      const query = utils.buildExploreRequest(form, columns, pageSettings);

      expect(query).toMatchObject(utils.sampleQuery);
      expect(query.page_settings.page).toBe(2);
    });
  });
});

describe('exploreUtils', () => {
  const data = {
    pages: {
      2: [
        {
          'last_updated': '2017-12-01',
          'name': 'Taps to Riches',
          'publisher_name': 'Game Circus LLC',
          'platform': 'ios',
          'mobile_priority': 'high',
          'current_version': '2.17',
          'publisher_id': 131716,
          'id': 2729366,
        },
      ],
    },
  };

  describe('formatResults', () => {
    it('should take in the response data and params and return an object of results formatted for the table reducer', () => {
      const data = {
        pages: {
          2: [
            {
              'last_updated': '2017-12-01',
              'name': 'Taps to Riches',
              'publisher_name': 'Game Circus LLC',
              'platform': 'ios',
              'mobile_priority': 'high',
              'current_version': '2.17',
              'publisher_id': 131716,
              'id': 2729366,
            },
          ],
        },
      };
      const query = utils.buildExploreRequest(form, columns, pageSettings);
      const results = formatResults(data, query);
      // const expected = {
      //   results: [],
      //   resultsCount: 1,
      //   pageSize: 1,
      //   pageNum: 1,
      //   sort: '',
      //   order: '',
      // };

      expect(Array.isArray(results.results)).toBe(true);
      expect(results.results[0].id).toBe(data.pages['2'][0].id);
      expect(results.pageNum).toBe(1);
    });
  });

  describe('extractPublisher', () => {
    it('should extract the publisher data from the app object and consolidate it into a single object', () => {
      const extracted = extractPublisher(data.pages[2][0]);

      expect(extracted.publisher_id).toBeUndefined();
      expect(extracted.publisher_name).toBeUndefined();
      expect(extracted.publisher).toEqual(expect.objectContaining({
        id: 131716,
        name: 'Game Circus LLC',
      }));
    });
  });
});
