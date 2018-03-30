import { all, call, takeEvery, takeLatest, select } from 'redux-saga/effects';
import ExploreMixpanelService from 'services/mixpanel/explore.mixpanel';
import * as selectors from 'selectors/explore.selectors';

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
    const currentState = yield select(selectors.takenDownFilter);
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
  const queryId = yield select(selectors.currentQueryId);
  const filters = yield select(selectors.activeFilters);
  const count = action.payload.data.resultsCount;
  yield call(service.trackResultsLoad, queryId, filters, count);
}

function* trackQueryFailure () {
  const filters = yield select(selectors.activeFilters);
  yield call(service.trackQueryFailure, filters);
}

function* trackCsvExport () {
  const id = yield select(selectors.csvQueryId);
  yield call(service.trackCsvExport, id);
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
  ]);
}
