import { all, put, call, takeLatest, select } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';
import { formatResults, setExploreColumns } from 'utils/explore/general.utils';
import { isFacebookOnly } from 'selectors/account.selectors';
import { buildCsvRequest } from 'utils/explore/queryBuilder.utils';
import toastr from 'toastr';

import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  GET_CSV_QUERY_ID,
  REQUEST_QUERY_PAGE,
  populateFromQueryId,
  tableActions,
  updateQueryId,
  updateQueryResultId,
  getCsvQueryId,
} from './Explore.actions';

const service = ExploreService;

function* requestResults ({ payload }) {
  const { params, params: { page_settings: { page: pageNum } } } = payload;
  delete params.page_settings.page;
  try {
    yield put(tableActions.clearResults());
    const { data: { query_id } } = yield call(service.getQueryId, params);
    put(getCsvQueryId.request(params));
    history.pushState(null, null, `#/search/v2/${query_id}`);
    yield call(requestResultsByQueryId, query_id, params, pageNum);
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
    throw error;
  }
}

function* requestResultsByQueryId (id, params, pageNum) {
  try {
    yield put(updateQueryId(id, JSON.parse(params.formState)));
    const res = yield call(service.getQueryResultInfo, id);
    const { number_results, query_result_id } = res.data;
    yield put(updateQueryResultId(query_result_id));
    if (number_results === 0) {
      yield put(tableActions.allItems.success({ resultsCount: 0 }));
    } else {
      const { data } = yield call(service.getResultsByResultId, query_result_id, pageNum);
      const items = formatResults(data, params, number_results);
      yield put(tableActions.allItems.success(items));
    }
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
    throw error;
  }
}

function* requestResultsByQueryResultId ({ payload: { id, page } }) {
  try {
    yield put(tableActions.setLoading(true));
    const { data } = yield call(service.getResultsByResultId, id, page);
    const items = formatResults(data);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
    throw error;
  }
}

function* populateFromQuery ({ payload: { id } }) {
  try {
    const { data: params, data: { formState } } = yield call(service.getQueryParams, id);
    yield put(populateFromQueryId.success(id, JSON.parse(formState)));
    yield put(tableActions.setLoading(true));
    yield put(getCsvQueryId.request(params));
    yield call(requestResultsByQueryId, id, params, 0);
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem loading the query.");
    yield put(populateFromQueryId.failure());
    yield put(tableActions.allItems.failure());
    throw error;
  }
}

function* requestCsvQueryId ({ payload: { params } }) {
  try {
    const facebookOnly = yield select(isFacebookOnly);
    const csvParams = buildCsvRequest(params, facebookOnly);
    const { data: { query_id } } = yield call(service.getQueryId, csvParams);
    const { data: { query_result_id } } = yield call(service.getQueryResultInfo, query_id);
    yield put(getCsvQueryId.success(query_result_id));
  } catch (error) {
    console.log(error);
    yield put(getCsvQueryId.failure());
    throw error;
  }
}

function updateExploreTableColumns ({ payload: { columns } }) {
  setExploreColumns(columns);
}

function* watchResultsRequest() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.REQUEST, requestResults);
}

function* watchQueryPopulation() {
  yield takeLatest(POPULATE_FROM_QUERY_ID.REQUEST, populateFromQuery);
}

function* watchCsvRequest() {
  yield takeLatest(GET_CSV_QUERY_ID.REQUEST, requestCsvQueryId);
}

function* watchColumnUpdate() {
  yield takeLatest(TABLE_TYPES.UPDATE_COLUMNS, updateExploreTableColumns);
}

function* watchPageChange() {
  yield takeLatest(REQUEST_QUERY_PAGE, requestResultsByQueryResultId);
}

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
    watchCsvRequest(),
    watchColumnUpdate(),
    watchPageChange(),
  ]);
}
