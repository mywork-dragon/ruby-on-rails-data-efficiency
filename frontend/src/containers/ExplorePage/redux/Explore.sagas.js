import { all, put, call, fork, takeLatest, select } from 'redux-saga/effects';
import service from 'services/explore.service';
import { formatResults, setExploreColumns, isCurrentQuery } from 'utils/explore/general.utils';
import { isFacebookOnly } from 'selectors/account.selectors';
import { buildCsvRequest } from 'utils/explore/queryBuilder.utils';
import validateFormState from 'utils/explore/formStateValidation.utils';
import toastr from 'toastr';
import {
  LOAD_SAVED_SEARCH,
  loadSavedSearch,
} from 'actions/Account.actions';

import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  REQUEST_QUERY_PAGE,
  populateFromQueryId,
  tableActions,
  updateQueryId,
  updateQueryResultId,
  getCsvQueryId,
} from './Explore.actions';

function* requestResults ({ payload }) {
  const { params, params: { page_settings: { page: pageNum } } } = payload;
  delete params.page_settings.page;
  try {
    const { data: { query_id } } = yield call(service.getQueryId, params);
    yield put(tableActions.clearResults());
    history.pushState(null, null, `#/search/v2/${query_id}`);
    yield fork(requestCsvQueryId, params);
    yield call(requestResultsByQueryId, query_id, params, pageNum);
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure(error));
  }
}

function* requestResultsByQueryId (id, params, pageNum) {
  if (!isCurrentQuery(id)) {
    history.pushState(null, null, `#/search/v2/${id}`);
  }
  try {
    yield put(updateQueryId(id, JSON.parse(params.formState)));
    const res = yield call(service.getQueryResultInfo, id);
    // this failure doesn't get caught
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
  }
}

function* populateFromQuery ({ payload: { id, searchId } }) {
  try {
    const { data: params, data: { formState } } = yield call(service.getQueryParams, id);
    const validatedForm = validateFormState(JSON.parse(formState));
    yield put(populateFromQueryId.success(id, validatedForm));
    yield put(tableActions.setLoading(true));
    if (searchId) {
      yield put(loadSavedSearch.success(searchId));
    }
    yield call(requestResultsByQueryId, id, params, 0);
    yield fork(requestCsvQueryId, params);
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem loading the query.");
    yield put(populateFromQueryId.failure(error));
    yield put(tableActions.allItems.failure(error));
  }
}

function* requestCsvQueryId (params) {
  try {
    yield put(getCsvQueryId.request());
    const facebookOnly = yield select(isFacebookOnly);
    const csvParams = buildCsvRequest(params, facebookOnly);
    const { data: { query_id } } = yield call(service.getQueryId, csvParams);
    const { data: { query_result_id, number_pages } } = yield call(service.getQueryResultInfo, query_id);
    yield put(getCsvQueryId.success(query_result_id, number_pages));
  } catch (error) {
    console.log(error);
    yield put(getCsvQueryId.failure(error));
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

function* watchSavedSearchLoad() {
  yield takeLatest(LOAD_SAVED_SEARCH.REQUEST, populateFromQuery);
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
    watchSavedSearchLoad(),
    watchColumnUpdate(),
    watchPageChange(),
  ]);
}
