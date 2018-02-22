import { all, takeLatest } from 'redux-saga/effects';
import { setPreferredPageSize } from 'utils/table.utils';

import { UPDATE_DEFAULT_PAGE_SIZE } from './Table.actions';

function updatePageSize ({ payload: { pageSize } }) {
  setPreferredPageSize(pageSize);
}

function* watchPageSizeUpdate() {
  yield takeLatest(UPDATE_DEFAULT_PAGE_SIZE, updatePageSize);
}

export default function* tableSaga() {
  yield all([
    watchPageSizeUpdate(),
  ]);
}
