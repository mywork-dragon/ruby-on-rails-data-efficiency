import { all, put, call, takeLatest } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';
import { formatResults, setExploreColumns } from 'utils/explore/general.utils';
import { buildCsvRequest } from 'utils/explore/queryBuilder.utils';
import toastr from 'toastr';

import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  GET_CSV_QUERY_ID,
  populateFromQueryId,
  tableActions,
  updateQueryId,
  getCsvQueryId,
} from './Explore.actions';

const service = ExploreService;

function* requestResults ({ payload }) {
  const { params, params: { page_settings: { page: pageNum } } } = payload;
  delete params.page_settings.page;
  try {
    yield put(tableActions.clearResults());
    const { data: { query_id } } = yield call(service.getQueryId, params);
    yield put(getCsvQueryId.request(params));
    history.pushState(null, null, `#/search/v2/${query_id}`);
    yield call(requestResultsByQueryId, query_id, params, pageNum);
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
  }
}

function* requestResultsByQueryId (id, params, pageNum) {
  try {
    yield put(updateQueryId(id));
    const res = yield call(service.getQueryResultInfo, id);
    const { number_results, query_result_id } = res.data;
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
  }
}

function* requestCsvQueryId ({ payload: { params } }) {
  try {
    const csvParams = buildCsvRequest(params);
    const { data: { query_id } } = yield call(service.getQueryId, csvParams);
    const { data: { query_result_id } } = yield call(service.getQueryResultInfo, query_id);
    yield put(getCsvQueryId.success(query_result_id));
  } catch (error) {
    console.log(error);
    yield put(getCsvQueryId.failure());
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

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
    watchCsvRequest(),
    watchColumnUpdate(),
  ]);
}
