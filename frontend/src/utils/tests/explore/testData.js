import { headerNames } from 'Table/redux/column.models';
import { initializeColumns } from '../../table.utils';

export const form = {
  resultType: 'app',
  platform: 'ios',
  includeTakenDown: false,
  filters: {
    sdks: {
      filters: [{
        sdks: [{ id: 114, platform: 'ios' }, { id: 200, platform: 'ios' }],
        eventType: 'install',
        dateRange: 'anytime',
        operator: 'any',
        installState: 'any-installed',
      }],
      operator: 'any',
    },
    fortuneRank: {
      value: 500,
      panelKey: '3',
      displayText: 'Fortune rank 500',
    },
    mobilePriority: {
      value: ['high', 'medium'],
      panelKey: '2',
      displayText: 'Mobile Priority High, Medium',
    },
    userBase: {
      value: ['elite'],
      panelKey: '2',
      displayText: 'User base Elite',
    },
  },
};

export const pageSettings = {
  pageSize: 20,
  pageNum: 1,
};

export const columns = initializeColumns([
  headerNames.APP,
  headerNames.PUBLISHER,
  headerNames.MOBILE_PRIORITY,
  headerNames.PLATFORM,
  headerNames.LAST_UPDATED,
]);

export const sort = [
  {
    id: headerNames.APP,
    desc: false,
  },
];

export const accountNetworks = {
  facebook: { id: 'facebook', can_access: true },
  applovin: { id: 'applovin', can_access: true },
  chartboost: { id: 'chartboost', can_access: true },
  mopub: { id: 'mopub', can_access: true },
  'unity-ads': { id: 'unity-ads', can_access: true },
};

export const mockResultsResponse = {
  pages: {
    2: [
      {
        'last_updated': '2017-12-01',
        'name': 'Taps to Riches',
        'publisher_name': 'Game Circus LLC',
        'platform': 'ios',
        'mobile_priority': 'high',
        'current_version': '2.17',
        'publisher_id': 131716,
        'id': 2729366,
        ad_summaries: [
          {
            ad_network: 'applovin',
            first_seen_ads_date: '2017-10-10',
            last_seen_ads_date: '2018-10-02',
            html_game: false,
            video: true,
          },
        ],
        categories: [{ type: 'primary', name: 'Games' }, { type: 'secondary', name: 'Puzzle' }],
        user_base: 'elite',
        all_version_rating: 4.7,
        all_version_ratings_count: 457,
        international_user_bases: [{ country: 'United States', user_base: 'weak', country_code: 'US' }],
      },
    ],
  },
};
