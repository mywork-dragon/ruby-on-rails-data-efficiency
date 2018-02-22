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
    const { data: { query_id } } = yield call(ExploreService().getQueryId, params);
    history.pushState(null, null, `#/search/v2/${query_id}`);
    yield put(updateQueryId(query_id));
    const { data, resultsCount } = yield call(ExploreService().getResultsByQueryId, query_id, pageNum);
    const items = formatResults(data, params, resultsCount);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
  }
}

function* requestFormState ({ payload: { id } }) {
  try {
    const { data: params, data: { formState } } = yield call(ExploreService().getQueryParams, id);
    const { data, resultsCount } = yield call(ExploreService().getResultsByQueryId, id, 0);
    const items = formatResults(data, params, resultsCount);
    yield put(populateFromQueryId.success(id, JSON.parse(formState)));
    yield put(tableActions.allItems.success(items));
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
  yield takeLatest(POPULATE_FROM_QUERY_ID.REQUEST, requestFormState);
}

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
  ]);
}
