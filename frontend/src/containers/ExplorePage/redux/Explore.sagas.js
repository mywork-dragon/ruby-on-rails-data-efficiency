import { all, put, call, takeLatest } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';
import { formatResults } from 'utils/explore/explore.utils';

import { TABLE_TYPES, tableActions } from './Explore.actions';

function* requestResults (action) {
  const { params, params: { page_settings: { page: pageNum } } } = action.payload;
  delete params.page_settings.page;
  try {
    const { data, resultsCount } = yield call(ExploreService().requestResults, params, pageNum);
    const items = formatResults(data, params, resultsCount);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
  }
}

function* watchResultsRequest() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.REQUEST, requestResults);
}

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
  ]);
}
