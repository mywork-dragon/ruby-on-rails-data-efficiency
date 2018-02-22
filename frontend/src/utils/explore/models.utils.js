import { headerNames } from 'Table/redux/column.models';

// map between frontend display fields and backend field
// place sort field at beginning of the list
export const selectMap = {
  [headerNames.APP]: ['name', 'id', 'current_version', 'icon_url', 'taken_down', 'app_identifier', 'first_scanned_date'],
  [headerNames.COUNTRIES_AVAILABLE_IN]: ['countries_available_in'],
  [headerNames.LAST_UPDATED]: ['last_updated'],
  [headerNames.MOBILE_PRIORITY]: ['mobile_priority'],
  [headerNames.PLATFORM]: ['platform'],
  [headerNames.PUBLISHER]: ['publisher'],
  [headerNames.RATINGS]: ['all_version_rating', 'all_version_ratings_count'],
  [headerNames.USER_BASE]: ['user_base'],
};

export const appFilterKeys = [
  'mobilePriority',
  'userBase',
];
