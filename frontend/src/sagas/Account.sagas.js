import { all, put, call, takeLatest } from 'redux-saga/effects';

import AccountService from 'services/account.service';

import {
  FETCH_AD_NETWORKS,
  loadAdNetworks,
} from 'actions/Account.actions';

function* requestAdNetworks() {
  try {
    const res = yield call(AccountService().getAdNetworks);
    yield put(loadAdNetworks(res.data));
  } catch (error) {
    console.log(error);
  }
}

function* watchAdNetworkFetch() {
  yield takeLatest(FETCH_AD_NETWORKS, requestAdNetworks);
}

export default function* accountSaga() {
  yield all([
    watchAdNetworkFetch(),
  ]);
}
