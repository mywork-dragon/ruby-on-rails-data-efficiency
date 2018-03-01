/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk category install event within a specified date range', () => {
    const filter = {
      sdks: [{
        id: 114,
        name: 'Analytics',
        type: 'sdkCategory',
        platform: 'ios',
        sdks: [12, 56, 234, 734, 34, 5],
      }],
      eventType: 'install',
      dateRange: 'custom',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          object: 'sdk_event',
          operator: 'filter',
          predicates: [
            ['type', 'install'],
            ['date', '2017-10-01', '2017-11-01'],
            ['sdk_ids', [12, 56, 234, 734, 34, 5]],
            ['platform', 'ios'],
          ],
        },
      ],
    };

    const sdkFilter = generateSdkFilter(filter);

    expect(sdkFilter).toMatchObject(expected);
    expect(sdkFilter.inputs).toEqual(expected.inputs);
    expect(sdkFilter.inputs[0].predicates).toEqual(expected.inputs[0].predicates);
    expect(sdkFilter.inputs[0].predicates[2][1]).toEqual(expected.inputs[0].predicates[2][1]);
  });
});
