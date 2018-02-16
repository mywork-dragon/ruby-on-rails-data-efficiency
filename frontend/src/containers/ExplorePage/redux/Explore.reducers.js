import { combineReducers } from 'redux';
import { table, headerNames, initializeColumns } from 'Table/redux/Table.reducers';
import updateSearchForm from 'utils/explore/searchForm.utils';
import { TABLE_TYPES } from './Explore.actions';

const initialFormState = {
  resultType: 'app',
  platform: 'all',
  includeTakenDown: false,
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
  headerNames.USER_BASE,
  headerNames.LAST_UPDATED,
];

const tableOptions = {
  columns: initializeColumns(columnOptions, initialColumns, [headerNames.APP]),
  sort: [
    { id: headerNames.APP, desc: false },
  ],
};

function searchForm (state = initialFormState, action) {
  switch (action.type) {
    case TABLE_TYPES.UPDATE_FILTER:
      return updateSearchForm(state, action);
    case TABLE_TYPES.CLEAR_FILTERS:
      return {
        ...initialFormState,
      };
    default:
      return state;
  }
}

const explorePage = combineReducers({
  searchForm,
  resultsTable: table(TABLE_TYPES, tableOptions),
});

export default explorePage;
