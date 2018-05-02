import { combineReducers } from 'redux';
import { table, headerNames } from 'Table/redux/Table.reducers';
import { LOAD_SAVED_SEARCH } from 'actions/Account.actions';
import searchForm from './searchForm.reducers';
import { appColumns, publisherColumns } from './tableColumns.models';
import {
  TABLE_TYPES,
  TOGGLE_FORM,
  TOGGLE_PANEL,
  UPDATE_QUERY_ID,
  POPULATE_FROM_QUERY_ID,
  GET_CSV_QUERY_ID,
  UPDATE_QUERY_RESULT_ID,
  UPDATE_SAVED_SEARCH_PAGE,
} from './Explore.actions';

const tableOptions = {
  columns: appColumns(),
  sort: [
    { id: headerNames.LAST_UPDATED, desc: true },
  ],
};

const initialState = {
  savedSearchExpanded: true,
  searchFormExpanded: true,
  searchPage: 0,
  panels: { 1: false, 2: false, 3: false, 4: false, 5: false },
  queryId: null,
  savedSearchId: null,
  queryResultId: null,
  csvQueryId: null,
  currentLoadedQuery: {},
  appColumns: appColumns(),
  publisherColumns: publisherColumns(),
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
        currentLoadedQuery: payload.formState || {},
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
    case UPDATE_SAVED_SEARCH_PAGE:
      return {
        ...state,
        searchPage: payload.page,
      };
    case TABLE_TYPES.UPDATE_COLUMNS:
      return {
        ...state,
        [`${payload.type}Columns`]: payload.columns,
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
