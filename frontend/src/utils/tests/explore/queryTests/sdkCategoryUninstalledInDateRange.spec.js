/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk category uninstall event within a specified date range', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [
          { id: 12, name: 'bob' },
          { id: 56, name: 'joe' },
          { id: 234, name: 'dan' },
          { id: 734, name: 'sue' },
          { id: 34, name: 'dave' },
          { id: 5, name: 'jan' },
        ],
        includedSdks: [
          { id: 12, name: 'bob' },
          { id: 56, name: 'joe' },
          { id: 234, name: 'dan' },
          { id: 734, name: 'sue' },
        ],
      }],
      eventType: 'uninstall',
      dateRange: 'custom',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
      installState: 'any-installed',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          operator: 'intersect',
          inputs: [
            {
              object: 'sdk_event',
              operator: 'filter',
              predicates: [
                ['type', 'uninstall'],
                ['date', '2017-10-01', '2017-11-01'],
                ['sdk_category', 'Analytics', 'ios', [34, 5]],
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
