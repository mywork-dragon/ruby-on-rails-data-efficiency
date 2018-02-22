import { combineReducers } from 'redux';
import { table, headerNames, initializeColumns } from 'Table/redux/Table.reducers';
import searchForm from './searchForm.reducers';
import {
  TABLE_TYPES,
  TOGGLE_FORM,
  UPDATE_ACTIVE_PANEL,
  UPDATE_QUERY_ID,
  POPULATE_FROM_QUERY_ID,
} from './Explore.actions';

const initialState = {
  expanded: true,
  activePanel: '',
  queryId: '',
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
  headerNames.USER_BASE,
  headerNames.LAST_UPDATED,
];

const tableOptions = {
  columns: initializeColumns(columnOptions, initialColumns, [headerNames.APP]),
  sort: [
    { id: headerNames.APP, desc: false },
  ],
};

function explore (state = initialState, action) {
  const { type, payload } = action;
  switch (type) {
    case TOGGLE_FORM:
      return {
        ...state,
        expanded: !state.expanded,
      };
    case UPDATE_ACTIVE_PANEL:
      return {
        ...state,
        activePanel: payload.index,
      };
    case POPULATE_FROM_QUERY_ID.SUCCESS:
    case UPDATE_QUERY_ID:
      return {
        ...state,
        queryId: payload.id,
      };
    case POPULATE_FROM_QUERY_ID.FAILURE:
      return {
        ...state,
        queryId: '',
      };
    default:
      return state;
  }
}

const explorePage = combineReducers({
  explore,
  searchForm,
  resultsTable: table(TABLE_TYPES, tableOptions),
});

export default explorePage;
