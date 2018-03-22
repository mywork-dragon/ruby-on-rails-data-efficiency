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
      eventType: 'install',
      dateRange: 'year',
      dates: [],
      operator: 'any',
      installState: 'is-installed',
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
                ['type', 'install'],
                [
                  'date',
                  ['-', ['utcnow'], ['timedelta', { years: 1 }]],
                  ['utcnow'],
                ],
                ['sdk_id', 114],
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
            {
              object: 'sdk',
              operator: 'filter',
              predicates: [
                ['installed'],
                ['id', 114],
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
