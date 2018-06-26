import React from 'react';
import { numberWithCommas, numberShorthand, longDate } from 'utils/format.utils';
import Rating from 'components/rating/Rating.component';

// header cells
import AdSpendHeaderCell from '../components/headerCells/AdSpendHeaderCell.component';
import DownloadsHeaderCell from '../components/headerCells/DownloadsHeaderCell.component';
import LastUpdatedHeaderCell from '../components/headerCells/LastUpdatedHeaderCell.component';
import HintTextHeaderCell from '../components/headerCells/HintTextHeaderCell.component';
import MobilePriorityHeaderCell from '../components/headerCells/MobilePriorityHeaderCell.component';
import RatingHeaderCell from '../components/headerCells/RatingHeaderCell.component';
import RatingsCountHeaderCell from '../components/headerCells/RatingsCountHeaderCell.component';
import UserBaseHeaderCell from '../components/headerCells/UserBaseHeaderCell.component';

// row cells
import AdAttributionSdkCell from '../components/cells/AdAttributionSdkCell.component';
import AdNetworkCellContainer from '../containers/AdNetworkCell.container';
import AdSpendCell from '../components/cells/AdSpendCell.component';
import AppNameCell from '../components/cells/AppNameCell.component';
import CategoryCell from '../containers/CategoryCell.container';
import CountryCell from '../containers/CountryCell.container';
import CreativeFormatCell from '../components/cells/CreativeFormatCell.component';
import DateCell from '../components/cells/DateCell.component';
import DomainCell from '../components/cells/DomainCell.component';
import FirstSeenAdsCell from '../components/cells/FirstSeenAdsCell.component';
import LastSeenAdsCell from '../components/cells/LastSeenAdsCell.component';
import LocationCell from '../components/cells/LocationCell.component';
import MobilePriorityCell from '../components/cells/MobilePriorityCell.component';
import NewcomerCell from '../components/cells/NewcomerCell.component';
import PermissionsCell from '../components/cells/PermissionsCell.component';
import PlatformCell from '../components/cells/PlatformCell.component';
import PublisherCell from '../components/cells/PublisherCell.component';
import RankCell from '../components/cells/RankCell.component';
import RankChangeCell from '../components/cells/RankChangeCell.component';
import UserBaseCell from '../components/cells/UserBaseCell.component';

const widths = {
  xSmall: 125,
  small: 150,
  medium: 200,
  mediumLarge: 250,
  large: 300,
  xLarge: 350,
};

export const headerNames = {
  AD_NETWORKS: 'Ad Networks',
  AD_SDKS: 'Ad Attribution SDKs',
  AD_SPEND: 'Ad Spend',
  APP: 'App',
  CATEGORY: 'Category',
  COUNTRIES_AVAILABLE_IN: 'Available In',
  COUNTRY: 'Country',
  CREATIVE_FORMATS: 'Formats',
  DOMAINS: 'Domains',
  DOWNLOADS: 'Downloads',
  ENTERED_CHART: 'Date Entered Chart',
  FIRST_SEEN_ADS: 'First Seen Ads',
  FORTUNE_RANK: 'Fortune Rank',
  LAST_SEEN_ADS: 'Last Seen Ads',
  LAST_UPDATED: 'Last Updated',
  LOCATIONS: 'Locations',
  MOBILE_PRIORITY: 'Mobile Priority',
  MONTHLY_CHANGE: '1 Month Rank Change',
  NUM_APPS: 'Total Apps',
  PERMISSIONS: 'Requested Permissions',
  PLATFORM: 'Platform',
  PUBLISHER: 'Publisher',
  RANK: 'Rank',
  RATING: 'Rating',
  RATINGS_COUNT: 'Ratings Count',
  RELEASE_DATE: 'Release Date',
  SIMPLE_ENTERED_CHART: 'Simple Entered Chart',
  SIMPLE_RANK: 'Simpe Rank',
  SIMPLE_MONTH_CHANGE: 'Simple 1 Month Rank Change',
  SIMPLE_WEEK_CHANGE: 'Simple 1 Week Rank Change',
  TOTAL_CREATIVES_SEEN: 'Total Creatives Seen',
  USER_BASE: 'User Base',
  WEEKLY_CHANGE: '1 Week Rank Change',
};

export const columnModels = [
  {
    Header: headerNames.AD_NETWORKS,
    id: headerNames.AD_NETWORKS,
    accessor: 'ad_networks',
    width: widths.xSmall,
    sortable: false,
    Cell: cell => <AdNetworkCellContainer networks={cell.value} />,
  },
  {
    Header: headerNames.AD_SDKS,
    id: headerNames.AD_SDKS,
    accessor: 'ad_attribution_sdks',
    width: widths.medium,
    sortable: false,
    Cell: cell => <AdAttributionSdkCell app={cell.original} />,
  },
  {
    Header: <AdSpendHeaderCell />,
    id: headerNames.AD_SPEND,
    accessor: 'adSpend',
    width: widths.xSmall,
    sortable: false,
    Cell: cell => <AdSpendCell adSpend={cell.value} />,
  },
  {
    Header: headerNames.APP,
    id: headerNames.APP,
    accessor: 'name',
    minWidth: widths.xLarge,
    Cell: cell => <AppNameCell app={cell.original} {...cell.tdProps.rest} />,
  },
  {
    Header: headerNames.CATEGORY,
    id: headerNames.CATEGORY,
    accessor: 'categories',
    minWidth: widths.small,
    sortable: false,
    Cell: cell => <CategoryCell categories={cell.original.categories || cell.original.category} platform={cell.original.platform} />,
  },
  {
    Header: headerNames.COUNTRY,
    id: headerNames.COUNTRY,
    accessor: 'country',
    minWidth: widths.medium,
    sortable: false,
    Cell: cell => <CountryCell country={cell.value} {...cell.tdProps.rest} />,
  },
  {
    Header: headerNames.CREATIVE_FORMATS,
    id: headerNames.CREATIVE_FORMATS,
    accessor: 'creative_formats',
    width: widths.xSmall,
    sortable: false,
    Cell: cell => <CreativeFormatCell formats={cell.value} />,
  },
  {
    Header: headerNames.DOMAINS,
    id: headerNames.DOMAINS,
    accessor: 'domains',
    width: widths.xSmall,
    sortable: false,
    Cell: cell => <DomainCell domains={cell.value} />,
  },
  {
    Header: <DownloadsHeaderCell />,
    id: headerNames.DOWNLOADS,
    accessor: 'downloads',
    width: widths.xSmall,
    Cell: cell => (typeof cell.value !== 'number' ? (
      <span className="invalid">Not available</span>
    ) : numberShorthand(cell.value) + "+"),
  },
  {
    Header: <HintTextHeaderCell title={headerNames.ENTERED_CHART} hintText="Only charts fulfilling the filter requirements are displayed; app may be ranked on additional charts" />,
    id: headerNames.ENTERED_CHART,
    accessor: 'newcomers',
    width: widths.large,
    Cell: cell => <NewcomerCell app={cell.original} {...cell.tdProps.rest} />,
  },
  {
    Header: headerNames.FIRST_SEEN_ADS,
    id: headerNames.FIRST_SEEN_ADS,
    accessor: 'first_seen_ads_date',
    width: widths.small,
    Cell: cell => <FirstSeenAdsCell app={cell.original} />,
  },
  {
    Header: headerNames.FORTUNE_RANK,
    id: headerNames.FORTUNE_RANK,
    accessor: 'fortuneRank',
    width: widths.xSmall,
  },
  {
    Header: headerNames.LAST_SEEN_ADS,
    id: headerNames.LAST_SEEN_ADS,
    accessor: 'last_seen_ads_date',
    width: widths.small,
    Cell: cell => <LastSeenAdsCell app={cell.original} />,
  },
  {
    Header: <LastUpdatedHeaderCell />,
    id: headerNames.LAST_UPDATED,
    accessor: d => d.lastUpdated || d.current_version_release_date,
    width: widths.small,
    Cell: cell => <DateCell type={cell.original.resultType} updateDate={cell.value} />,
  },
  {
    Header: headerNames.LOCATIONS,
    id: headerNames.LOCATIONS,
    accessor: 'locations',
    width: widths.small,
    sortable: false,
    Cell: cell => <LocationCell locations={cell.value} />,
  },
  {
    Header: <MobilePriorityHeaderCell />,
    id: headerNames.MOBILE_PRIORITY,
    accessor: d => ['low', 'medium', 'high'].indexOf(d.mobilePriority || d.mobile_priority),
    minWidth: widths.small,
    Cell: cell => <MobilePriorityCell mobilePriority={cell.value} />,
  },
  {
    Header: <HintTextHeaderCell title={headerNames.MONTHLY_CHANGE} hintText="Only charts fulfilling the filter requirements are displayed; app may be ranked on additional charts" />,
    id: headerNames.MONTHLY_CHANGE,
    accessor: 'rankings',
    minWidth: widths.large,
    Cell: cell => <RankChangeCell app={cell.original} changeType="month" {...cell.tdProps.rest} />,
  },
  {
    Header: headerNames.NUM_APPS,
    id: headerNames.NUM_APPS,
    accessor: 'number_of_apps',
    headerClassName: 'small-cell',
    className: 'small-cell',
    Cell: cell => cell.value,
  },
  {
    Header: headerNames.PERMISSIONS,
    id: headerNames.PERMISSIONS,
    accessor: 'permissions',
    minWidth: widths.medium,
    Cell: cell => <PermissionsCell permissions={cell.value} {...cell.tdProps} />,
  },
  {
    Header: 'Type',
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
    minWidth: widths.xLarge,
    accessor: d => d.publisher || d,
    Cell: (cell) => <PublisherCell platform={cell.original.platform} publisher={cell.value} {...cell.tdProps.rest} />,
  },
  {
    Header: <HintTextHeaderCell title={headerNames.RANK} hintText="Only charts fulfilling the filter requirements are displayed; app may be ranked on additional charts" />,
    id: headerNames.RANK,
    minWidth: widths.large,
    accessor: 'rank',
    Cell: (cell) => <RankCell app={cell.original} {...cell.tdProps.rest} />,
  },
  {
    Header: <RatingHeaderCell />,
    id: headerNames.RATING,
    accessor: 'rating',
    width: widths.xSmall,
    Cell: cell => <Rating rating={cell.value} />,
  },
  {
    Header: <RatingsCountHeaderCell />,
    id: headerNames.RATINGS_COUNT,
    accessor: 'ratingsCount',
    width: widths.small,
    Cell: cell => (cell.value ? numberWithCommas(cell.value) : <span className="invalid">No ratings</span>),
  },
  {
    Header: headerNames.RELEASE_DATE,
    id: headerNames.RELEASE_DATE,
    accessor: 'original_release_date',
    width: widths.xSmall,
    Cell: cell => <DateCell releaseDate={cell.value} />,
  },
  {
    Header: 'Date Entered Chart',
    id: headerNames.SIMPLE_ENTERED_CHART,
    accessor: 'date',
    Cell: cell => (cell.value ? longDate(cell.value) : 'N/A'),
  },
  {
    Header: 'Rank',
    id: headerNames.SIMPLE_RANK,
    accessor: 'rank',
    width: widths.small,
  },
  {
    Header: '1 Week Rank Change',
    id: headerNames.SIMPLE_WEEK_CHANGE,
    accessor: 'weekly_change',
    width: widths.medium,
    Cell: (cell) => {
      if (cell.value < 0) {
        return <span style={{ color: 'red' }}>{cell.value}</span>;
      } else if (cell.value > 0) {
        return <span style={{ color: 'green' }}>{cell.value}</span>;
      } else if (cell.value === 0) {
        return cell.value;
      }
      return 'N/A';
    },
  },
  {
    Header: '1 Month Rank Change',
    id: headerNames.SIMPLE_MONTH_CHANGE,
    accessor: 'monthly_change',
    width: widths.medium,
    Cell: (cell) => {
      if (cell.value < 0) {
        return <span style={{ color: 'red' }}>{cell.value}</span>;
      } else if (cell.value > 0) {
        return <span style={{ color: 'green' }}>{cell.value}</span>;
      } else if (cell.value === 0) {
        return cell.value;
      }
      return 'N/A';
    },
  },
  {
    Header: headerNames.TOTAL_CREATIVES_SEEN,
    id: headerNames.TOTAL_CREATIVES_SEEN,
    accessor: 'number_of_creatives',
    width: widths.medium,
  },
  {
    Header: <UserBaseHeaderCell />,
    id: headerNames.USER_BASE,
    accessor: 'userBase',
    width: widths.xSmall,
    sortable: false,
    Cell: cell => <UserBaseCell app={cell.original} />,
  },
  {
    Header: <HintTextHeaderCell title={headerNames.WEEKLY_CHANGE} hintText="Only charts fulfilling the filter requirements are displayed; app may be ranked on additional charts" />,
    id: headerNames.WEEKLY_CHANGE,
    accessor: 'rankings',
    minWidth: widths.large,
    Cell: cell => <RankChangeCell app={cell.original} changeType="week" {...cell.tdProps.rest} />,
  },
];
