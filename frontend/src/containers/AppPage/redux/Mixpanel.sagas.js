import { all, call, takeEvery, select } from 'redux-saga/effects';
import AppRankingsMixpanelService from 'services/mixpanel/appRankings.mixpanel';
import { getAllSelectedOptions } from 'selectors/rankingsTab.selectors';
import { RANKINGS_TAB_ACTION_TYPES, RANKINGS_CHART } from '../components/rankings-tab/redux/RankingsTab.actions';

const service = AppRankingsMixpanelService();

function* trackFilterChange ({ type }) {
  const params = yield select(getAllSelectedOptions);
  yield call(service.trackFilterChange, { ...params, actionType: type });
}

function* trackChartLoad() {
  const params = yield select(getAllSelectedOptions);
  yield call(service.trackChartLoad, params);
}

function* trackTableSort(action) {
  yield call(service.trackTableSort, action.payload);
}

function* watchRankingsFilterChange() {
  yield takeEvery([
    RANKINGS_TAB_ACTION_TYPES.UPDATE_COUNTRIES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_CATEGORIES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_RANKING_TYPES_FILTER,
    RANKINGS_TAB_ACTION_TYPES.UPDATE_DATE_RANGE,
  ], trackFilterChange);
}

function* watchRankingsChartLoad() {
  yield takeEvery(RANKINGS_CHART.SUCCESS, trackChartLoad);
}

function* watchTableSort() {
  yield takeEvery(RANKINGS_TAB_ACTION_TYPES.UPDATE_TABLE_SORT, trackTableSort);
}

export default function* appRankingsMixpanelSaga() {
  yield all([
    watchRankingsFilterChange(),
    watchRankingsChartLoad(),
    watchTableSort(),
  ]);
}
