import { all, put, call, takeLatest } from 'redux-saga/effects';

import AppService from 'services/app.service';
import PublisherService from 'services/publisher.service';

import {
  PUBLISHER_AD_INTEL_ACTION_TYPES as pubTypes,
  publisherAdIntelActions as pubActions,
  pubAdIntelAppTableActions as appTable,
} from 'containers/PublisherPage/redux/Publisher.actions';

import {
  APP_AD_INTEL_ACTION_TYPES as appTypes,
  appAdIntelActions as appActions,
} from 'containers/AppPage/redux/App.actions';

import { formatAppAdData, formatAppCreatives } from 'utils/app.utils';
import { formatPublisherAdData, formatPublisherCreatives } from 'utils/publisher.utils';

function* requestAppAdIntelInfo(action) {
  const { id, platform } = action.payload;
  try {
    yield put({ type: appTypes.CLEAR_AD_INTEL_INFO });
    const res = yield call(AppService().getAdIntelInfo, id, platform);
    const data = res.data ? formatAppAdData(res.data) : null;
    yield put(appActions.loadAdIntelInfo(id, platform, data));
  } catch (error) {
    console.log(error);
    yield put(appActions.adIntelError(id, platform));
  }
}

function* requestPublisherAdIntelInfo(action) {
  const { id, platform } = action.payload;
  try {
    yield put({ type: pubTypes.CLEAR_AD_INTEL_INFO });
    const res = yield call(PublisherService().getAdIntelInfo, id, platform);
    const data = res.data ? formatPublisherAdData(res.data) : null;
    yield put(pubActions.loadAdIntelInfo(id, platform, data));
    if (data != null) yield put(appTable.loadApps(data.advertising_apps));
  } catch (error) {
    console.log(error);
    yield put(pubActions.adIntelError(id, platform));
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
    yield put(appActions.loadCreatives(id, data));
  } catch (error) {
    console.log(error);
  }
}

function* requestPublisherCreatives(action) {
  const {
    id,
    platform,
    params,
  } = action.payload;
  try {
    const res = yield call(PublisherService().getCreatives, id, platform, params);
    const data = formatPublisherCreatives(res.data);
    yield put(pubActions.loadCreatives(id, data));
  } catch (error) {
    console.log(error);
  }
}

function* watchAppAdIntelInfoRequest() {
  yield takeLatest(appTypes.AD_INTEL_INFO_REQUEST, requestAppAdIntelInfo);
}

function* watchPublisherAdIntelInfoRequest() {
  yield takeLatest(pubTypes.AD_INTEL_INFO_REQUEST, requestPublisherAdIntelInfo);
}

function* watchAppCreativesRequest() {
  yield takeLatest(appTypes.CREATIVES_REQUEST, requestAppCreatives);
}

function* watchPublisherCreativesRequest() {
  yield takeLatest(pubTypes.CREATIVES_REQUEST, requestPublisherCreatives);
}

export default function* adIntelSaga() {
  yield all([
    watchAppAdIntelInfoRequest(),
    watchPublisherAdIntelInfoRequest(),
    watchAppCreativesRequest(),
    watchPublisherCreativesRequest(),
  ]);
}
