import { all, put, call, takeLatest } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';
import { formatResults } from 'utils/explore/general.utils';
import toastr from 'toastr';

import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  populateFromQueryId,
  tableActions,
  updateQueryId,
} from './Explore.actions';

function* requestResults (action) {
  const { params, params: { page_settings: { page: pageNum } } } = action.payload;
  delete params.page_settings.page;
  try {
    yield put(tableActions.clearResults());
    const { data: { query_id } } = yield call(ExploreService().getQueryId, params);
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
    const res = yield call(ExploreService().getQueryResultInfo, id);
    const { number_results, query_result_id } = res.data;
    if (number_results === 0) {
      yield put(tableActions.allItems.success({ resultsCount: 0 }));
    } else {
      const { data } = yield call(ExploreService().getResultsByResultId, query_result_id, pageNum);
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
    const { data: params, data: { formState } } = yield call(ExploreService().getQueryParams, id);
    yield put(populateFromQueryId.success(id, JSON.parse(formState)));
    yield call(requestResultsByQueryId, id, params, 0);
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem loading the query.");
    yield put(populateFromQueryId.failure());
    yield put(tableActions.allItems.failure());
  }
}

function* watchResultsRequest() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.REQUEST, requestResults);
}

function* watchQueryPopulation() {
  yield takeLatest(POPULATE_FROM_QUERY_ID.REQUEST, populateFromQuery);
}

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
  ]);
}
