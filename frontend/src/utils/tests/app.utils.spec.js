/* eslint-env jest */

import * as utils from '../app.utils';
import * as data from '../mocks/mock-data.utils';

describe('App Utils', () => {
  describe('formatAppAdData', () => {
    it('should take in a response and return the relevant app data', () => {
      const result = Object.values(data.appSummary)[0];

      expect(utils.formatAppAdData(data.appSummary)).toEqual(result);
    });
  });

  describe('formatAppCreatives', () => {
    it('should take in a response and return an object containing the list of creatives, resultsCount, pageNum, and pageSize', () => {
      const response = data.appCreatives({ pageNum: 1 });
      const creatives = Object.values(response.results)[0].creatives;
      const formattedData = utils.formatAppCreatives(response);

      expect(Array.isArray(creatives)).toBe(true);
      expect(formattedData).toEqual(expect.objectContaining({
        results: creatives,
        pageNum: 1,
      }));
    });
  });

  describe('addAdIds', () => {
    const ads = [{ name: '1' }, { name: '2' }];
    const formattedAds = utils.addAdIds(ads);

    expect(formattedAds[0].id).toBe(0);
    expect(formattedAds[1].id).toBe(1);
  });
});
