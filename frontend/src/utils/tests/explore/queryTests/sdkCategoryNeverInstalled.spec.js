/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk category never installed', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [12, 56, 234, 734, 34, 5],
      }],
      eventType: 'never-seen',
      dateRange: 'custom',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          operator: 'intersect',
          inputs: [
            {
              operator: 'not',
              inputs: [
                {
                  object: 'sdk_event',
                  operator: 'filter',
                  predicates: [
                    ['type', 'install'],
                    ['sdk_ids', [12, 56, 234, 734, 34, 5]],
                    ['platform', 'ios'],
                  ],
                },
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
