import { combineReducers } from 'redux';
import { table, headerNames, initializeColumns } from 'Table/redux/Table.reducers';
import { LOAD_SAVED_SEARCH } from 'actions/Account.actions';
import { setExploreColumns, getExploreColumns } from 'utils/explore/general.utils';
import searchForm from './searchForm.reducers';
import {
  TABLE_TYPES,
  TOGGLE_FORM,
  TOGGLE_PANEL,
  UPDATE_QUERY_ID,
  POPULATE_FROM_QUERY_ID,
  GET_CSV_QUERY_ID,
  UPDATE_QUERY_RESULT_ID,
} from './Explore.actions';

const initialState = {
  savedSearchExpanded: true,
  searchFormExpanded: true,
  panels: { 1: false, 2: false, 3: false, 4: false, 5: false },
  queryId: null,
  savedSearchId: null,
  queryResultId: null,
  csvQueryId: null,
  currentLoadedQuery: {},
};

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

const initializedColumns = initializeColumns(columnOptions, initialColumns, [headerNames.APP]);

let savedColumns = getExploreColumns();

if (!savedColumns) {
  setExploreColumns(initializedColumns);
  savedColumns = initializedColumns;
} else if (Object.keys(savedColumns).length !== Object.keys(initializedColumns).length) {
  savedColumns = { ...initializedColumns, ...savedColumns };
}

const tableOptions = {
  columns: savedColumns,
  sort: [
    { id: headerNames.LAST_UPDATED, desc: true },
  ],
};

function explore (state = initialState, action) {
  const { type, payload } = action;
  switch (type) {
    case TOGGLE_FORM:
      return {
        ...state,
        [`${payload.type}Expanded`]: !state[`${payload.type}Expanded`],
      };
    case TOGGLE_PANEL:
      return {
        ...state,
        panels: {
          ...state.panels,
          [payload.index]: !state.panels[payload.index],
        },
      };
    case POPULATE_FROM_QUERY_ID.REQUEST:
    case POPULATE_FROM_QUERY_ID.SUCCESS:
    case UPDATE_QUERY_ID:
      return {
        ...state,
        queryId: payload.id,
        currentLoadedQuery: payload.formState,
      };
    case LOAD_SAVED_SEARCH.SUCCESS:
      return {
        ...state,
        savedSearchId: payload.id,
      };
    case GET_CSV_QUERY_ID.REQUEST:
      return {
        ...state,
        csvQueryId: null,
      };
    case GET_CSV_QUERY_ID.SUCCESS:
      return {
        ...state,
        csvQueryId: payload.id,
      };
    case UPDATE_QUERY_RESULT_ID:
      return {
        ...state,
        queryResultId: payload.id,
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
