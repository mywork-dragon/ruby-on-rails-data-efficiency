import { all, put, call, takeLatest } from 'redux-saga/effects';

import AccountService from 'services/account.service';

import {
  AD_NETWORKS,
  adNetworks,
} from 'actions/Account.actions';

function* requestAdNetworks() {
  try {
    const res = yield call(AccountService().getAdNetworks);
    yield put(adNetworks.success(res.data));
  } catch (error) {
    console.log(error);
  }
}

function* watchAdNetworkFetch() {
  yield takeLatest(AD_NETWORKS.REQUEST, requestAdNetworks);
}

export default function* accountSaga() {
  yield all([
    watchAdNetworkFetch(),
  ]);
}
