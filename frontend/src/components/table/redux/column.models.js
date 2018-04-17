import React from 'react';
import { numberWithCommas, numberShorthand } from 'utils/format.utils';
import Rating from 'components/rating/Rating.component';

// header cells
import AdSpendHeaderCell from '../components/headerCells/AdSpendHeaderCell.component';
import DownloadsHeaderCell from '../components/headerCells/DownloadsHeaderCell.component';
import MobilePriorityHeaderCell from '../components/headerCells/MobilePriorityHeaderCell.component';
import RatingHeaderCell from '../components/headerCells/RatingHeaderCell.component';
import UserBaseHeaderCell from '../components/headerCells/UserBaseHeaderCell.component';

// row cells
import AdAttributionSdkCell from '../components/cells/AdAttributionSdkCell.component';
import AdNetworkCellContainer from '../containers/AdNetworkCell.container';
import AdSpendCell from '../components/cells/AdSpendCell.component';
import AppNameCell from '../components/cells/AppNameCell.component';
import CreativeFormatCell from '../components/cells/CreativeFormatCell.component';
import FirstSeenAdsCell from '../components/cells/FirstSeenAdsCell.component';
import LastSeenAdsCell from '../components/cells/LastSeenAdsCell.component';
import DateCell from '../components/cells/DateCell.component';
import MobilePriorityCell from '../components/cells/MobilePriorityCell.component';
import PlatformCell from '../components/cells/PlatformCell.component';
import PublisherCell from '../components/cells/PublisherCell.component';
import UserBaseCell from '../components/cells/UserBaseCell.component';

const widths = {
  small: 125,
  medium: 150,
  large: 200,
  extraLarge: 250,
};

export const headerNames = {
  AD_NETWORKS: 'Ad Networks',
  AD_SDKS: 'Ad Attribution SDKs',
  AD_SPEND: 'Ad Spend',
  APP: 'App',
  CATEGORY: 'Category',
  COUNTRIES_AVAILABLE_IN: 'Available In',
  CREATIVE_FORMATS: 'Formats',
  DOWNLOADS: 'Downloads',
  FIRST_SEEN_ADS: 'First Seen Ads',
  FORTUNE_RANK: 'Fortune Rank',
  LAST_SEEN_ADS: 'Last Seen Ads',
  LAST_UPDATED: 'Last Updated',
  MOBILE_PRIORITY: 'Mobile Priority',
  PLATFORM: 'Platform',
  PUBLISHER: 'Publisher',
  RATING: 'Rating',
  RATINGS_COUNT: 'Ratings Count',
  RELEASE_DATE: 'Release Date',
  TOTAL_CREATIVES_SEEN: 'Total Creatives Seen',
  USER_BASE: 'User Base',
};

export const columnModels = [
  {
    Header: headerNames.AD_NETWORKS,
    id: headerNames.AD_NETWORKS,
    accessor: 'ad_networks',
    width: widths.small,
    sortable: false,
    Cell: cell => <AdNetworkCellContainer networks={cell.value} />,
  },
  {
    Header: headerNames.AD_SDKS,
    id: headerNames.AD_SDKS,
    accessor: 'ad_attribution_sdks',
    width: widths.large,
    sortable: false,
    Cell: cell => <AdAttributionSdkCell app={cell.original} />,
  },
  {
    Header: <AdSpendHeaderCell />,
    id: headerNames.AD_SPEND,
    accessor: 'adSpend',
    width: widths.small,
    sortable: false,
    Cell: cell => <AdSpendCell adSpend={cell.value} />,
  },
  {
    Header: headerNames.APP,
    id: headerNames.APP,
    accessor: 'name',
    minWidth: widths.extraLarge,
    Cell: cell => <AppNameCell app={cell.original} {...cell.tdProps} />,
  },
  {
    Header: headerNames.CATEGORY,
    id: headerNames.CATEGORY,
    accessor: 'categories',
    minWidth: widths.medium,
    sortable: false,
    Cell: cell => <div>{cell.value.length ? cell.value.join(', ') : <span className="invalid">No data</span>}</div>,
  },
  {
    Header: headerNames.CREATIVE_FORMATS,
    id: headerNames.CREATIVE_FORMATS,
    accessor: 'creative_formats',
    width: widths.small,
    sortable: false,
    Cell: cell => <CreativeFormatCell formats={cell.value} />,
  },
  {
    Header: <DownloadsHeaderCell />,
    id: headerNames.DOWNLOADS,
    accessor: 'downloads',
    width: widths.small,
    Cell: cell => (typeof cell.value !== 'number' ? (
      <span className="invalid">Not available</span>
    ) : numberShorthand(cell.value) + "+"),
  },
  {
    Header: headerNames.FIRST_SEEN_ADS,
    id: headerNames.FIRST_SEEN_ADS,
    accessor: 'first_seen_ads_date',
    width: widths.medium,
    Cell: cell => <FirstSeenAdsCell app={cell.original} />,
  },
  {
    Header: headerNames.FORTUNE_RANK,
    id: headerNames.FORTUNE_RANK,
    accessor: 'fortuneRank',
    width: widths.small,
  },
  {
    Header: headerNames.LAST_SEEN_ADS,
    id: headerNames.LAST_SEEN_ADS,
    accessor: 'last_seen_ads_date',
    width: widths.medium,
    Cell: cell => <LastSeenAdsCell app={cell.original} />,
  },
  {
    Header: headerNames.LAST_UPDATED,
    id: headerNames.LAST_UPDATED,
    accessor: d => d.lastUpdated || d.current_version_release_date,
    width: widths.medium,
    Cell: cell => <DateCell updateDate={cell.value} />,
  },
  {
    Header: <MobilePriorityHeaderCell />,
    id: headerNames.MOBILE_PRIORITY,
    accessor: d => ['low', 'medium', 'high'].indexOf(d.mobilePriority || d.mobile_priority),
    minWidth: widths.medium,
    Cell: cell => <MobilePriorityCell mobilePriority={cell.value} />,
  },
  {
    Header: 'App Type',
    id: headerNames.PLATFORM,
    accessor: 'platform',
    width: 50,
    sortable: false,
    className: 'platform-cell',
    Cell: cell => <PlatformCell platform={cell.value} />,
  },
  {
    Header: headerNames.PUBLISHER,
    id: headerNames.PUBLISHER,
    minWidth: widths.extraLarge,
    accessor: d => (d.publisher ? d.publisher.name : ''),
    Cell: cell => <PublisherCell platform={cell.original.platform} publisher={cell.original.publisher} {...cell.tdProps} />,
  },
  {
    Header: <RatingHeaderCell />,
    id: headerNames.RATING,
    accessor: 'all_version_rating',
    width: widths.small,
    Cell: cell => <Rating rating={cell.value} />,
  },
  {
    Header: headerNames.RATINGS_COUNT,
    id: headerNames.RATINGS_COUNT,
    accessor: 'all_version_ratings_count',
    width: widths.small,
    Cell: cell => (cell.value ? numberWithCommas(cell.value) : <span className="invalid">No ratings</span>),
  },
  {
    Header: headerNames.RELEASE_DATE,
    id: headerNames.RELEASE_DATE,
    accessor: 'original_release_date',
    width: widths.small,
    Cell: cell => <DateCell releaseDate={cell.value} />,
  },
  {
    Header: headerNames.TOTAL_CREATIVES_SEEN,
    id: headerNames.TOTAL_CREATIVES_SEEN,
    accessor: 'number_of_creatives',
    width: widths.large,
  },
  {
    Header: <UserBaseHeaderCell />,
    id: headerNames.USER_BASE,
    accessor: 'userBase',
    width: widths.small,
    sortable: false,
    Cell: cell => <UserBaseCell app={cell.original} />,
  },
];
