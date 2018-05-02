import { headerNames, syncColumns } from 'Table/redux/Table.reducers';
import { setExploreColumns, getExploreColumns } from 'utils/explore/general.utils';

export function appColumns () {
  const columnOptions = [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.PLATFORM,
    headerNames.MOBILE_PRIORITY,
    // headerNames.FORTUNE_RANK,
    headerNames.AD_NETWORKS,
    headerNames.FIRST_SEEN_ADS,
    headerNames.LAST_SEEN_ADS,
    headerNames.USER_BASE,
    headerNames.AD_SPEND,
    headerNames.CATEGORY,
    headerNames.DOWNLOADS,
    headerNames.RANK,
    headerNames.WEEKLY_CHANGE,
    headerNames.MONTHLY_CHANGE,
    headerNames.ENTERED_CHART,
    headerNames.RATING,
    headerNames.RATINGS_COUNT,
    headerNames.RELEASE_DATE,
    headerNames.LAST_UPDATED,
  ];

  const initialColumns = [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.PLATFORM,
    headerNames.MOBILE_PRIORITY,
    headerNames.USER_BASE,
    headerNames.CATEGORY,
    headerNames.RELEASE_DATE,
    headerNames.LAST_UPDATED,
  ];

  const lockedColumns = [
    headerNames.APP,
  ];

  const savedColumns = getExploreColumns('app');
  const finalColumns = syncColumns(savedColumns, columnOptions, initialColumns, lockedColumns);

  setExploreColumns('app', finalColumns);

  return finalColumns;
}

export function publisherColumns () {
  const columnOptions = [
    headerNames.PUBLISHER,
    headerNames.PLATFORM,
    headerNames.NUM_APPS,
    headerNames.FORTUNE_RANK,
    headerNames.AD_NETWORKS,
    headerNames.FIRST_SEEN_ADS,
    headerNames.LAST_SEEN_ADS,
    headerNames.LOCATIONS,
    headerNames.DOMAINS,
    headerNames.RATING,
    headerNames.RATINGS_COUNT,
    headerNames.DOWNLOADS,
    headerNames.LAST_UPDATED,
  ];

  const initialColumns = [
    headerNames.PUBLISHER,
    headerNames.PLATFORM,
    headerNames.NUM_APPS,
    headerNames.LOCATIONS,
    headerNames.DOMAINS,
    headerNames.RATING,
    headerNames.RATINGS_COUNT,
    headerNames.DOWNLOADS,
    headerNames.LAST_UPDATED,
  ];

  const lockedColumns = [
    headerNames.PUBLISHER,
    headerNames.PLATFORM,
    headerNames.NUM_APPS,
    headerNames.LAST_UPDATED,
  ];

  const savedColumns = getExploreColumns('publisher');
  const finalColumns = syncColumns(savedColumns, columnOptions, initialColumns, lockedColumns);

  setExploreColumns('publisher', finalColumns);

  return finalColumns;
}
