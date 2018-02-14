/* eslint-env jest */

import * as utils from '../publisher.utils';
import * as data from '../mocks/mock-data.utils';

describe('Publisher Utils', () => {
  describe('formatPublisherAdData', () => {
    it('should take in a response and return the relevant app data', () => {
      const formattedData = utils.formatPublisherAdData(data.publisherAdSummary);

      expect(formattedData).toEqual(expect.objectContaining({
        number_of_creatives: expect.any(Number),
        creative_formats: expect.arrayContaining(['video', 'html', 'image']),
        total_apps: expect.any(Number),
        first_seen_ads_date: expect.any(Date),
      }));
    });
  });

  describe('formatPublisherCreatives', () => {
    it('should take in a response and return an object containing the list of creatives, resultsCount, pageNum, and pageSize', () => {
      const response = data.publisherCreatives({ pageNum: 1 });
      // const creatives = Object.values(response.results)[0].creatives;
      const formattedData = utils.formatPublisherCreatives(response);

      expect(formattedData).toEqual(expect.objectContaining({
        pageNum: expect.any(Number),
      }));
      expect(Array.isArray(formattedData.results)).toBe(true);
    });
  });
});
