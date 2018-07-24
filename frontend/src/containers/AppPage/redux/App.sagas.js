import { all, put, call, takeLatest, select } from 'redux-saga/effects';
import * as utils from 'utils/app.utils';
import { $localStorage } from 'utils/localStorage.utils';
import AppService from 'services/app.service';
import {
  AD_INTEL_TYPES as actionTypes,
  adIntelActions,
} from 'containers/AppPage/redux/App.actions';
import { getAllSelectedOptions } from 'selectors/rankingsTab.selectors';
import {
  RANKINGS_TAB_ACTION_TYPES,
  rankingsChart,
  RANKINGS_CHART,
} from '../components/rankings-tab/redux/RankingsTab.actions';

function* requestAppAdIntelInfo(action) {
  const { id, platform } = action.payload;
  try {
    yield put({ type: actionTypes.CLEAR_AD_INTEL_INFO });
    const res = yield call(AppService().getAdIntelInfo, id, platform);
    const data = res.data ? utils.formatAppAdData(res.data) : null;
    yield put(adIntelActions.adIntelInfo.success(id, platform, data));
  } catch (error) {
    console.log(error);
    yield put(adIntelActions.adIntelInfo.failure(id, platform));
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
    const data = utils.formatAppCreatives(res.data);
    yield put(adIntelActions.creatives.success(id, data));
  } catch (error) {
    console.log(error);
  }
}

function* requestChartData(action) {
  try {
    if (action.type !== RANKINGS_CHART.REQUEST) {
      yield put(rankingsChart.request());
    }
    const selectedOptions = yield select(getAllSelectedOptions);
    const params = utils.formatRankingsParams(selectedOptions);
    if (JSON.parse(params.countries).length === 0) {
      yield put(rankingsChart.failure('Must select a country'));
    } else {
      const { data } = yield call(AppService().getHistoricalRankings, params);
      yield put(rankingsChart.success(data));
    }
  } catch (error) {
    console.log(error);
    yield put(rankingsChart.failure());
  }
}

function updateDefaultCountries ({ payload: { countries } }) {
  $localStorage.set('defaultRankingsCountries', countries);
}

function* watchRankingsFilterChange() {
  yield takeLatest([
    RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_CATEGORIES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_RANKING_TYPES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_DATE_RANGE,
    RANKINGS_CHART.REQUEST,
  ], requestChartData);
}

function* watchAppAdIntelInfoRequest() {
  yield takeLatest(actionTypes.AD_INTEL_INFO.REQUEST, requestAppAdIntelInfo);
}

function* watchAppCreativesRequest() {
  yield takeLatest(actionTypes.CREATIVES.REQUEST, requestAppCreatives);
}

function* watchRankingsCountriesChange() {
  yield takeLatest(RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER, updateDefaultCountries);
}

export default function* appSaga() {
  yield all([
    watchAppAdIntelInfoRequest(),
    watchAppCreativesRequest(),
    watchRankingsFilterChange(),
    watchRankingsCountriesChange(),
  ]);
}
