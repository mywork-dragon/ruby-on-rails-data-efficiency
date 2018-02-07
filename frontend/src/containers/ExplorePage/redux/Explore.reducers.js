import { combineReducers } from 'redux';
import { table, headerNames, initializeColumns } from 'Table/redux/Table.reducers';
import { TABLE_TYPES } from './Explore.actions';

const initialFormState = {
  resultType: 'apps',
  platform: 'all',
  filters: {},
};

const columnOptions = [
  headerNames.APP,
  headerNames.PUBLISHER,
  headerNames.PLATFORM,
  headerNames.MOBILE_PRIORITY,
  headerNames.FORTUNE_RANK,
  headerNames.AD_NETWORKS,
  headerNames.FIRST_SEEN_ADS,
  headerNames.LAST_SEEN_ADS,
  headerNames.USER_BASE,
  headerNames.AD_SPEND,
  headerNames.CATEGORY,
  headerNames.LAST_UPDATED,
];

const initialColumns = [
  headerNames.APP,
  headerNames.PUBLISHER,
  headerNames.PLATFORM,
  headerNames.MOBILE_PRIORITY,
  headerNames.AD_SPEND,
  headerNames.USER_BASE,
  headerNames.CATEGORY,
  headerNames.LAST_UPDATED,
];

const tableOptions = {
  columns: initializeColumns(columnOptions, initialColumns, [headerNames.APP]),
  sort: [
    { id: headerNames.LAST_UPDATED, desc: true },
  ],
};

function searchForm (state = initialFormState, action) {
  switch (action.type) {
    default:
      return state;
  }
}

const explorePage = combineReducers({
  searchForm,
  tableOptions,
  resultsTable: table(TABLE_TYPES, tableOptions),
});

export default explorePage;
