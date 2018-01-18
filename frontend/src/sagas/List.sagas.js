import { all, put, call, takeLatest, takeEvery } from 'redux-saga/effects';
import toastr from 'toastr';

import ListService from 'services/list.service';

import {
  loadLists,
  FETCH_LISTS,
  CLEAR_LISTS,
  ADD_SELECTED_APPS_TO_LIST,
} from 'actions/List.actions';

function* requestLists() {
  try {
    yield put({ type: CLEAR_LISTS });
    const res = yield call(ListService().getLists);
    yield put(loadLists(res.data));
  } catch (error) {
    console.log(error);
  }
}

function* addSelectedAppsToList(action) {
  const { id, apps } = action.payload;
  try {
    if (apps.length) {
      yield call(ListService().addToList, id, apps);
      toastr.success('Items successfully added to list!');
    } else {
      toastr.warning('No items selected!');
    }
  } catch (error) {
    console.log(error);
    toastr.error('Whoops! There was a problem adding items to the list.');
  }
}

function* watchListFetch() {
  yield takeLatest(FETCH_LISTS, requestLists);
}

function* watchItemAdd() {
  yield takeEvery(ADD_SELECTED_APPS_TO_LIST, addSelectedAppsToList);
}

export default function* listSaga() {
  yield all([
    watchListFetch(),
    watchItemAdd(),
  ]);
}
