/* eslint-env jest */

import * as utils from '../../explore/sdkFilterBuilder.utils';
import { sampleQuery } from './sampleQuery';
import * as testData from './testData';

describe('buildFilter', () => {
  describe('generateSdkItem', () => {
    it('should take in an sdk and return the ID for the query', () => {
      const sdk = { id: 114, type: 'sdk' };
      const expected = ['sdk_id', 114];
      const result = utils.generateSdkItem(sdk);

      expect(result).toEqual(expected);
    });

    it('should take in an sdkCategory and return the sdk category for the query', () => {
      const sdkCategory = {
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
          [34, 'dave'],
          [5, 'jan'],
        ],
        includedSdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
          [34, 'dave'],
          [5, 'jan'],
        ],
      };
      const expected = ['sdk_category', 'Analytics', 'ios'];
      const result = utils.generateSdkItem(sdkCategory);

      expect(result).toEqual(expected);
    });

    it('should take in an sdkCategory and return the sdk category and any excluded sdks for the query', () => {
      const sdkCategory = {
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
          [34, 'dave'],
          [5, 'jan'],
        ],
        includedSdks: [
          [12, 'bob'],
          [56, 'joe'],
          [234, 'dan'],
          [734, 'sue'],
        ],
      };
      const expected = ['sdk_category', 'Analytics', 'ios', [34, 5]];
      const result = utils.generateSdkItem(sdkCategory);

      expect(result).toEqual(expected);
    });
  });

  describe('generateDateRange', () => {
    it('should return nothing if dateRange is anytime or if eventType is never-seen', () => {

      expect(utils.generateDateRange({ dateRange: 'anytime' })).toBeNull();
      expect(utils.generateDateRange({ eventType: 'never-seen' })).toBeNull();
    });

    it('should return a relative time range if dateRange is relative', () => {
      const expected = [
        'date',
        ['-', ['utcnow'], ['timedelta', { days: 7 }]],
        ['utcnow'],
      ];

      expect(utils.generateDateRange({ dateRange: 'week' })).toEqual(expected);
    });

    it('should return a specified date range using provided dates if the dateRange is custom', () => {
      const expected = ['date', '2017-10-01', '2017-11-01'];
      const result = utils.generateDateRange({ dateRange: 'custom', dates: ['2017-10-01', '2017-11-01'] });

      expect(result).toEqual(expected);
    });
  });

  describe('buildSdkFilters', () => {
    it('should take in the filter portion of the search form and return the publisher filters for the query', () => {
      const sdkFilters = utils.buildSdkFilters(testData.form.filters);

      expect(sdkFilters).toMatchObject(sampleQuery.query.filter.inputs[2]);
    });
  });
});
