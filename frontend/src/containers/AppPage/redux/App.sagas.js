import { all, put, call, takeLatest } from 'redux-saga/effects';
import { formatAppAdData, formatAppCreatives } from 'utils/app.utils';
import AppService from 'services/app.service';
// import { appSummary, appCreatives } from 'utils/mock-data.utils';

import {
  AD_INTEL_TYPES as actionTypes,
  adIntelActions,
} from 'containers/AppPage/redux/App.actions';

function* requestAppAdIntelInfo(action) {
  const { id, platform } = action.payload;
  try {
    yield put({ type: actionTypes.CLEAR_AD_INTEL_INFO });
    const res = yield call(AppService().getAdIntelInfo, id, platform);
    const data = res.data ? formatAppAdData(res.data) : null;
    yield put(adIntelActions.adIntelInfo.success(id, platform, data));
  } catch (error) {
    console.log(error);
    yield put(adIntelActions.adIntelInfo.failure(id, platform));
    // const data = formatAppAdData(appSummary);
    // yield put(adIntelActions.adIntelInfo.success(id, platform, data));
  }
}

function* requestAppCreatives(action) {
  const {
    id,
    platform,
    params,
  } = action.payload;
  try {
    const res = yield call(AppService().getCreatives, id, platform, params);
    const data = formatAppCreatives(res.data);
    yield put(adIntelActions.creatives.success(id, data));
  } catch (error) {
    console.log(error);
    // const data = formatAppCreatives(appCreatives(params));
    // yield put(adIntelActions.creatives.success(id, data));
  }
}

function* watchAppAdIntelInfoRequest() {
  yield takeLatest(actionTypes.AD_INTEL_INFO.REQUEST, requestAppAdIntelInfo);
}

function* watchAppCreativesRequest() {
  yield takeLatest(actionTypes.CREATIVES.REQUEST, requestAppCreatives);
}

export default function* appSaga() {
  yield all([
    watchAppAdIntelInfoRequest(),
    watchAppCreativesRequest(),
  ]);
}
