import { combineReducers } from 'redux';
import { table, headerNames } from 'Table/redux/Table.reducers';
import { EXPLORE_TABLE_ACTION_TYPES } from './Explore.actions';

const initialFormState = {
  resultType: 'apps',
  platform: 'all',
  filters: {},
};

const initialTableOptionsState = {
  columnOptions: [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.MOBILE_PRIORITY,
    headerNames.FORTUNE_RANK,
    headerNames.AD_NETWORKS,
    headerNames.LAST_UPDATED,
    headerNames.FIRST_SEEN_ADS,
    headerNames.LAST_SEEN_ADS,
    headerNames.USER_BASE,
    headerNames.AD_SPEND,
    headerNames.CATEGORY,
  ],
  pageSize: 20,
  pageNum: 1,
  resultType: 'app',
  activeColumns: [
    headerNames.APP,
    headerNames.PUBLISHER,
    headerNames.MOBILE_PRIORITY,
    headerNames.AD_SPEND,
    headerNames.USER_BASE,
    headerNames.CATEGORY,
    headerNames.LAST_UPDATED,
  ],
  sort: { id: headerNames.LAST_UPDATED, desc: true },
};

function searchForm (state = initialFormState, action) {
  switch (action.type) {
    default:
      return state;
  }
}

function tableOptions (state = initialTableOptionsState, action) {
  switch (action.type) {
    default:
      return state;
  }
}

const explore = combineReducers({
  searchForm,
  tableOptions,
  resultsTable: table(EXPLORE_TABLE_ACTION_TYPES),
});

export default explore;
