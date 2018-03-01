/* eslint-env jest */

import { buildFilter, buildAppFilters, buildPublisherFilters } from '../../explore/filterBuilder.utils';
import { sampleQuery } from './sampleQuery';
import * as testData from './testData';

describe('buildFilter', () => {
  describe('buildAppFilters', () => {
    it('should take in the search form and return the app filters for the query', () => {
      const appFilters = buildAppFilters(testData.form);

      expect(appFilters).toMatchObject(sampleQuery.query.filter.inputs[0]);
    });
  });

  describe('buildPublisherFilters', () => {
    it('should take in the search form and return the publisher filters for the query', () => {
      const publisherFilters = buildPublisherFilters(testData.form);

      expect(publisherFilters).toMatchObject(sampleQuery.query.filter.inputs[1]);
    });
  });

  describe('buildFilter', () => {
    it('should take in the search form and return the filter portion of the formatted query', () => {
      const filter = buildFilter(testData.form);

      expect(filter).toMatchObject(sampleQuery.query);
    });
  });
});
