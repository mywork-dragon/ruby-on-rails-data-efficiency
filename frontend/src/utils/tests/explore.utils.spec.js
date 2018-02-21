/* eslint-env jest */
/* eslint camelcase: 0, quote-props: 0 */

import { headerNames } from 'Table/redux/column.models';
import * as utils from '../explore/queryBuilder.utils';
import { buildFilter, buildAppFilters, buildSdkFilters } from '../explore/filterBuilder.utils';
import { sampleQuery } from '../explore/sampleQuery';
import { initializeColumns } from '../table.utils';
import { formatResults, getSortName } from '../explore/general.utils';

const pageSettings = {
  pageSize: 20,
  pageNum: 1,
};
const form = {
  resultType: 'app',
  platform: 'ios',
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
const sort = [
  {
    id: headerNames.APP,
    desc: false,
  },
];

describe('buildExploreRequest', () => {
  describe('buildPageSettings', () => {
    it('should take an object containing page settings and return a query formatted object containing page settings', () => {
      const page_settings = utils.buildPageSettings(pageSettings);

      expect(page_settings.page_size).toBe(pageSettings.pageSize);
      expect(page_settings.page).toBe(pageSettings.pageNum);
    });
  });

  describe('buildSortSettings', () => {
    it('should take a list of sorts and return sort settings for the query', () => {
      const sort_settings = utils.buildSortSettings(sort);

      expect(Array.isArray(sort_settings.fields)).toBe(true);
      expect(sort_settings.fields[0]).toMatchObject(sampleQuery.sort.fields[0]);
    });
  });

  describe('getSortName', () => {
    it('should take in a select field and return the corresponding sort/display field', () => {
      expect(getSortName('name')).toBe(headerNames.APP);
      expect(getSortName('last_updated')).toBe(headerNames.LAST_UPDATED);
    });
  });

  describe('buildSelect', () => {
    it('should take in a result type and map of columns and return an object containing the select parameters for the query', () => {
      const select = utils.buildSelect(form.resultType, columns);

      expect(select).toMatchObject(sampleQuery.select);
    });
  });

  describe('buildExploreRequest', () => {
    it('should take in the search form, the columns, the page settings, and the sort and return a formatted query', () => {
      const query = utils.buildExploreRequest(form, columns, pageSettings, sort);

      expect(query).toMatchObject(sampleQuery);
      expect(query.page_settings.page).toBe(1);
    });
  });
});

describe('buildFilter', () => {
  describe('buildAppFilters', () => {
    it('should take in the search form and return the app filters for the query', () => {
      const appFilters = buildAppFilters(form);

      expect(appFilters).toMatchObject(sampleQuery.query.filter.inputs[0]);
    });
  });

  // TODO: add later
  // describe('buildSdkFilters', () => {
  //   it('should take in the search form and return the sdk filters for the query', () => {
  //
  //   });
  // });

  describe('buildFilter', () => {
    it('should take in the search form and return the filter portion of the formatted query', () => {
      const filter = buildFilter(form);

      expect(filter).toMatchObject(sampleQuery.query);
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
      const query = utils.buildExploreRequest(form, columns, pageSettings, sort);
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
      expect(results.pageNum).toBe(2);
    });
  });
});
