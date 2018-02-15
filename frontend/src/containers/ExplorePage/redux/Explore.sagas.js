import { all, put, call, takeLatest } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';
import { formatResults } from 'utils/explore/explore.utils';

import { TABLE_TYPES, tableActions } from './Explore.actions';

function* requestResults (action) {
  const { params } = action.payload;
  try {
    const res = yield call(ExploreService().requestResults, params);
    const items = formatResults(res.data, params);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
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
