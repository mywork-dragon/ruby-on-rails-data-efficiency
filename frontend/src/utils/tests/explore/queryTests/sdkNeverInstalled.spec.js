/* eslint-env jest */

import { generateSdkFilter } from '../../../explore/sdkFilterBuilder.utils';

describe('buildSdkFilters', () => {
  it('should create a filter for an sdk never installed', () => {
    const filter = {
      sdks: [
        {
          id: 114,
          name: 'Tune',
          type: 'sdk',
          platform: 'ios',
        },
        {
          id: 200,
          name: 'Tune',
          type: 'sdk',
          platform: 'ios',
        },
      ],
      eventType: 'never-seen',
      dateRange: 'custom',
      dates: ['2017-10-01', '2017-11-01'],
      operator: 'any',
    };

    const expected = {
      operator: 'union',
      inputs: [
        {
          operator: 'not',
          inputs: [
            {
              object: 'sdk_event',
              operator: 'filter',
              predicates: [
                ['type', 'install'],
                ['sdk_id', 114],
                ['platform', 'ios'],
              ],
            },
          ],
        },
        {
          operator: 'not',
          inputs: [
            {
              object: 'sdk_event',
              operator: 'filter',
              predicates: [
                ['type', 'install'],
                ['sdk_id', 200],
                ['platform', 'ios'],
              ],
            },
          ],
        },
      ],
    };

    const sdkFilter = generateSdkFilter(filter);

    expect(sdkFilter).toMatchObject(expected);
    expect(sdkFilter.inputs).toEqual(expected.inputs);
    expect(sdkFilter.inputs[0].inputs[0].predicates).toEqual(expected.inputs[0].inputs[0].predicates);
  });
});
