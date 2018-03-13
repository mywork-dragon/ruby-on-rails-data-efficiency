import React from 'react';
import { longDate } from 'utils/format.utils';

// header cells
import AdSpendHeaderCell from '../components/headerCells/AdSpendHeaderCell.component';
import MobilePriorityHeaderCell from '../components/headerCells/MobilePriorityHeaderCell.component';
import UserBaseHeaderCell from '../components/headerCells/UserBaseHeaderCell.component';

// row cells
import AdAttributionSdkCell from '../components/cells/AdAttributionSdkCell.component';
import AdNetworkCellContainer from '../containers/AdNetworkCell.container';
import AdSpendCell from '../components/cells/AdSpendCell.component';
import AppNameCell from '../components/cells/AppNameCell.component';
import CreativeFormatCell from '../components/cells/CreativeFormatCell.component';
import LastUpdatedCell from '../components/cells/LastUpdatedCell.component';
import MobilePriorityCell from '../components/cells/MobilePriorityCell.component';
import PlatformCell from '../components/cells/PlatformCell.component';
import PublisherCell from '../components/cells/PublisherCell.component';
import UserBaseCell from '../components/cells/UserBaseCell.component';

export const headerNames = {
  AD_NETWORKS: 'Ad Networks',
  AD_SDKS: 'Ad Attribution SDKs',
  AD_SPEND: 'Ad Spend',
  APP: 'App',
  CATEGORY: 'Category',
  COUNTRIES_AVAILABLE_IN: 'Available In',
  CREATIVE_FORMATS: 'Formats',
  FIRST_SEEN_ADS: 'First Seen Ads',
  FORTUNE_RANK: 'Fortune Rank',
  LAST_SEEN_ADS: 'Last Seen Ads',
  LAST_UPDATED: 'Last Updated',
  MOBILE_PRIORITY: 'Mobile Priority',
  PLATFORM: 'Platform',
  PUBLISHER: 'Publisher',
  RATINGS: 'Ratings',
  TOTAL_CREATIVES_SEEN: 'Total Creatives Seen',
  USER_BASE: 'User Base',
};

export const columnModels = [
  {
    Header: headerNames.AD_NETWORKS,
    id: headerNames.AD_NETWORKS,
    accessor: 'ad_networks',
    className: 'med-small-cell',
    headerClassName: 'med-small-cell',
    sortable: false,
    Cell: cell => <AdNetworkCellContainer networks={cell.value} />,
  },
  {
    Header: headerNames.AD_SDKS,
    id: headerNames.AD_SDKS,
    accessor: 'ad_attribution_sdks',
    className: 'large-cell',
    headerClassName: 'large-cell',
    sortable: false,
    Cell: cell => <AdAttributionSdkCell app={cell.original} />,
  },
  {
    Header: <AdSpendHeaderCell />,
    id: headerNames.AD_SPEND,
    accessor: 'adSpend',
    headerClassName: 'small-cell',
    className: 'small-cell',
    Cell: cell => <AdSpendCell adSpend={cell.value} />,
  },
  {
    Header: headerNames.APP,
    id: headerNames.APP,
    accessor: 'name',
    className: 'name-cell',
    headerClassName: 'name-cell',
    Cell: cell => <AppNameCell app={cell.original} />,
  },
  {
    Header: headerNames.CATEGORY,
    id: headerNames.CATEGORY,
    accessor: 'categories',
    headerClassName: 'med-cell',
    className: 'med-cell',
    Cell: cell => <div>{cell.value.join(', ')}</div>,
  },
  {
    Header: headerNames.CREATIVE_FORMATS,
    id: headerNames.CREATIVE_FORMATS,
    accessor: 'creative_formats',
    className: 'small-cell',
    headerClassName: 'small-cell',
    sortable: false,
    Cell: cell => <CreativeFormatCell formats={cell.value} />,
  },
  {
    Header: headerNames.FIRST_SEEN_ADS,
    id: headerNames.FIRST_SEEN_ADS,
    accessor: 'first_seen_ads_date',
    headerClassName: 'med-cell',
    className: 'med-cell',
    Cell: d => (d.value ? longDate(d.value) : 'No ad data'),
  },
  {
    Header: headerNames.FORTUNE_RANK,
    id: headerNames.FORTUNE_RANK,
    accessor: 'fortuneRank',
    headerClassName: 'small-cell',
    className: 'small-cell',
  },
  {
    Header: headerNames.LAST_SEEN_ADS,
    id: headerNames.LAST_SEEN_ADS,
    accessor: 'last_seen_ads_date',
    headerClassName: 'med-cell',
    className: 'med-cell',
    Cell: d => (d.value ? longDate(d.value) : 'No ad data'),
  },
  {
    Header: headerNames.LAST_UPDATED,
    id: headerNames.LAST_UPDATED,
    accessor: d => d.lastUpdated || d.last_updated,
    headerClassName: 'med-cell',
    className: 'med-cell',
    Cell: cell => <LastUpdatedCell date={cell.value} />,
  },
  {
    Header: <MobilePriorityHeaderCell />,
    id: headerNames.MOBILE_PRIORITY,
    accessor: d => ['low', 'medium', 'high'].indexOf(d.mobilePriority || d.mobile_priority),
    headerClassName: 'med-small-cell',
    className: 'med-small-cell',
    Cell: cell => <MobilePriorityCell mobilePriority={cell.value} />,
  },
  {
    Header: 'App Type',
    id: headerNames.PLATFORM,
    accessor: 'platform',
    headerClassName: 'platform-cell',
    className: 'platform-cell',
    sortable: false,
    Cell: cell => <PlatformCell platform={cell.value} />,
  },
  {
    Header: headerNames.PUBLISHER,
    id: headerNames.PUBLISHER,
    accessor: d => (d.publisher ? d.publisher.name : ''),
    headerClassName: 'name-cell',
    className: 'name-cell',
    Cell: (cell) => {
      if (cell.original.publisher) {
        return <PublisherCell platform={cell.original.platform} publisher={cell.original.publisher} />
      }
      return '';
    },
  },
  {
    Header: headerNames.TOTAL_CREATIVES_SEEN,
    id: headerNames.TOTAL_CREATIVES_SEEN,
    accessor: 'number_of_creatives',
    headerClassName: 'large-cell',
    className: 'large-cell',
  },
  {
    Header: <UserBaseHeaderCell />,
    id: headerNames.USER_BASE,
    accessor: 'userBase',
    headerClassName: 'small-cell',
    className: 'small-cell',
    Cell: cell => <UserBaseCell app={cell.original} />,
  },
];
