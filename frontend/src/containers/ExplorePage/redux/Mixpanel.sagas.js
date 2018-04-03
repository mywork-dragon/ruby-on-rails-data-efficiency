import { all, call, takeEvery, takeLatest, select } from 'redux-saga/effects';
import ExploreMixpanelService from 'services/mixpanel/explore.mixpanel';
import * as exploreSelectors from 'selectors/explore.selectors';
import * as accountSelectors from 'selectors/account.selectors';
import * as account from 'actions/Account.actions';
import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  REQUEST_QUERY_PAGE,
  TRACK_TABLE_SORT,
} from './Explore.actions';


const service = ExploreMixpanelService();

function* trackFilterAdded (action) {
  const { parameter } = action.payload;
  let { value } = action.payload;
  if (parameter === 'includeTakenDown') {
    const currentState = yield select(exploreSelectors.takenDownFilter);
    value = !currentState;
  }
  yield call(service.trackFilterAdded, parameter, value);
}

function* trackQueryPopulation (action) {
  yield call(service.trackQueryPopulation, action.payload.id);
}

function* trackColumnUpdate (action) {
  yield call(service.trackColumnUpdate, action.payload.columns);
}

function* trackPageThrough (action) {
  const { id, page } = action.payload;
  yield call(service.trackPageThrough, id, page);
}

function* trackTableSort (action) {
  yield call(service.trackTableSort, action.payload.sort);
}

function* trackResultsLoad (action) {
  const queryId = yield select(exploreSelectors.currentQueryId);
  const filters = yield select(exploreSelectors.activeFilters);
  const count = action.payload.data.resultsCount;
  yield call(service.trackResultsLoad, queryId, filters, count);
}

function* trackQueryFailure () {
  const filters = yield select(exploreSelectors.activeFilters);
  yield call(service.trackQueryFailure, filters);
}

function* trackCsvExport () {
  const id = yield select(exploreSelectors.csvQueryId);
  yield call(service.trackCsvExport, id);
}

function* trackSavedSearchCreate ({ payload: { search: { id, name, queryId } } }) {
  yield call(service.trackSavedSearchCreate, id, name, queryId);
}

function* trackSavedSearchLoad ({ payload: { searchId } }) {
  const search = yield select(accountSelectors.getSavedSearchById, searchId);
  yield call(service.trackSavedSearchLoad, search.id, search.name, search.queryId);
}

function* trackSavedSearchDelete ({ payload: { id }}) {
  const search = yield select(accountSelectors.getSavedSearchById, id);
  yield call(service.trackSavedSearchDelete, search.id, search.name, search.queryId);
}

function* watchFilterAdd() {
  yield takeEvery(TABLE_TYPES.UPDATE_FILTER, trackFilterAdded);
}

function* watchQueryPopulation() {
  yield takeLatest(POPULATE_FROM_QUERY_ID.SUCCESS, trackQueryPopulation);
}

function* watchColumnChange() {
  yield takeLatest(TABLE_TYPES.UPDATE_COLUMNS, trackColumnUpdate);
}

function* watchPageThrough() {
  yield takeLatest(REQUEST_QUERY_PAGE, trackPageThrough);
}

function* watchTableSort() {
  yield takeLatest(TRACK_TABLE_SORT, trackTableSort);
}

function* watchResultsLoad() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.SUCCESS, trackResultsLoad);
}

function* watchQueryFailure() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.FAILURE, trackQueryFailure);
}

function* watchCsvExport() {
  yield takeLatest(TABLE_TYPES.CSV_EXPORTED, trackCsvExport);
}

function* watchSavedSearchCreate() {
  yield takeLatest(account.SAVE_NEW_SEARCH.SUCCESS, trackSavedSearchCreate);
}

function* watchSavedSearchLoad() {
  yield takeLatest(account.LOAD_SAVED_SEARCH.REQUEST, trackSavedSearchLoad);
}

function* watchSavedSearchDelete() {
  yield takeLatest(account.DELETE_SAVED_SEARCH.REQUEST, trackSavedSearchDelete);
}

export default function* exploreMixpanelSaga() {
  yield all([
    watchFilterAdd(),
    watchQueryPopulation(),
    watchColumnChange(),
    watchPageThrough(),
    watchTableSort(),
    watchResultsLoad(),
    watchQueryFailure(),
    watchCsvExport(),
    watchSavedSearchCreate(),
    watchSavedSearchLoad(),
    watchSavedSearchDelete(),
  ]);
}
