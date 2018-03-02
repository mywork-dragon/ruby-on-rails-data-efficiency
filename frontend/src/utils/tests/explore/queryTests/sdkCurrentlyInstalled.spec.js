/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk currently installed', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Tune',
        type: 'sdk',
        platform: 'ios',
      }],
      eventType: 'is-installed',
      dateRange: 'anytime',
      dates: [],
      operator: 'any',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          operator: 'intersect',
          inputs: [
            {
              object: 'sdk',
              operator: 'filter',
              predicates: [
                ['installed'],
                ['id', 114],
                ['platform', 'ios'],
              ],
            },
            {
              object: 'app',
              operator: 'filter',
              predicates: [
                ['platform', 'ios'],
              ],
            },
          ],
        },
      ],
    };

    const sdkFilter = generateSdkFilter(filter);

    expect(sdkFilter).toEqual(expected);
  });
});
