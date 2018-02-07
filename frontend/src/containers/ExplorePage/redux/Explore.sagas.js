import { all, put, call, takeLatest } from 'redux-saga/effects';
import ExploreService from 'services/explore.service';

import { TABLE_TYPES, tableActions } from './Explore.actions';

function* requestResults (action) {
  const { params } = action.payload;
  try {
    const data = yield call(ExploreService().requestResults, params);
    yield put(tableActions.allItems.success(data));
  } catch (error) {
    console.log(error);
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
