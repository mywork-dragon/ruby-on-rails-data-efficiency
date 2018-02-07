import { all, put, call, takeLatest } from 'redux-saga/effects';
import { formatPublisherAdData, formatPublisherCreatives } from 'utils/publisher.utils';
import PublisherService from 'services/publisher.service';
// import { publisherAdSummary, publisherCreatives } from 'utils/mock-data.utils';

import {
  AD_INTEL_TYPES as actionTypes,
  adIntelActions,
  tableActions,
} from 'containers/PublisherPage/redux/Publisher.actions';

function* requestPublisherAdIntelInfo(action) {
  const { id, platform } = action.payload;
  try {
    yield put({ type: actionTypes.CLEAR_AD_INTEL_INFO });
    const res = yield call(PublisherService().getAdIntelInfo, id, platform);
    const data = res.data ? formatPublisherAdData(res.data, platform) : null;
    yield put(adIntelActions.adIntelInfo.success(id, platform, data));
    if (data != null) yield put(tableActions.allItems.success(data.advertising_apps));
  } catch (error) {
    console.log(error);
    yield put(adIntelActions.adIntelInfo.failure(id, platform));
    // const data = formatPublisherAdData(publisherAdSummary, platform);
    // yield put(adIntelActions.adIntelInfo.success(id, platform, data));
    // yield put(tableActions.allItems.success(data.advertising_apps));
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
    yield put(adIntelActions.creatives.success(id, data));
  } catch (error) {
    console.log(error);
    // const data = formatPublisherCreatives(publisherCreatives(params));
    // yield put(adIntelActions.creatives.success(id, data));
  }
}

function* watchPublisherAdIntelInfoRequest() {
  yield takeLatest(actionTypes.AD_INTEL_INFO.REQUEST, requestPublisherAdIntelInfo);
}

function* watchPublisherCreativesRequest() {
  yield takeLatest(actionTypes.CREATIVES.REQUEST, requestPublisherCreatives);
}

export default function* publisherSaga() {
  yield all([
    watchPublisherAdIntelInfoRequest(),
    watchPublisherCreativesRequest(),
  ]);
}
