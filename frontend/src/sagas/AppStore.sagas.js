import { all, put, call, takeLatest } from 'redux-saga/effects';
import AppStoreService from 'services/appStore.service';
import ExploreService from 'services/explore.service';
import * as actions from 'actions/AppStore.actions';
import * as utils from 'utils/appStore.utils';
// import { androidCategories, iosCategories } from 'utils/mocks/mock-categories.utils';

function* requestCategories () {
  try {
    const iosRes = yield call(AppStoreService().getIosCategories);
    const androidRes = yield call(AppStoreService().getAndroidCategories);
    const data = {};
    // data.iosCategoriesById = formatCategories(iosCategories);
    // data.androidCategoriesById = formatCategories(androidCategories);
    data.iosCategoriesById = utils.formatCategories(iosRes.data);
    data.androidCategoriesById = utils.formatCategories(androidRes.data);
    yield put(actions.categories.success(data));
  } catch (err) {
    console.log(err);
    yield put(actions.categories.failure(err));
  }
}

function* requestAvailableCountries () {
  try {
    const { data: { results } } = yield call(AppStoreService().getCountryAutocompleteResults, 1, '');
    yield put(actions.availableCountries.success(results));
  } catch (err) {
    console.log(err);
    yield put(actions.availableCountries.failure(err));
  }
}

function* requestSdkCategories () {
  try {
    const iosRes = yield call(AppStoreService().getIosSdkCategories);
    const androidRes = yield call(AppStoreService().getAndroidSdkCategories);
    const data = {};
    data.iosCategoriesById = iosRes.data;
    data.androidCategoriesById = androidRes.data;
    yield put(actions.sdkCategories.success(data));
  } catch (err) {
    console.log(err);
    yield put(actions.sdkCategories.failure(err));
  }
}

function* requestRankingsCountries () {
  try {
    const { data } = yield call(AppStoreService().getRankingsCountries);
    yield put(actions.rankingsCountries.success(data));
  } catch (error) {
    console.log(error);
    yield put(actions.rankingsCountries.failure(error));
  }
}

function* requestAppPermissionsOptions () {
  try {
    const { data } = yield call(ExploreService.getAppPermissionsOptions);
    yield put(actions.appPermissionsOptions.success(data));
  } catch (error) {
    console.log(error);
    yield put(actions.appPermissionsOptions.failure(error));
  }
}

function* requestGeoOptions () {
  try {
    const { data } = yield call(ExploreService.getGeoOptions);
    const headquarters = utils.formatHeadquarterData(data);
    yield put(actions.geoOptions.success(headquarters));
  } catch (error) {
    console.log(error);
    yield put(actions.geoOptions.failure(error));
  }
}

function* watchCategoriesRequest() {
  yield takeLatest(actions.CATEGORIES.REQUEST, requestCategories);
}

function* watchCountryRequest() {
  yield takeLatest(actions.AVAILABLE_COUNTRIES.REQUEST, requestAvailableCountries);
}

function* watchSdkCategoriesRequest() {
  yield takeLatest(actions.SDK_CATEGORIES.REQUEST, requestSdkCategories);
}

function* watchRankingsCategoriesRequest() {
  yield takeLatest(actions.RANKINGS_COUNTRIES.REQUEST, requestRankingsCountries);
}

function* watchAppPermissionsOptionsRequest() {
  yield takeLatest(actions.APP_PERMISSIONS_OPTIONS.REQUEST, requestAppPermissionsOptions);
}

function* watchGeoOptionsRequest() {
  yield takeLatest(actions.GEO_OPTIONS.REQUEST, requestGeoOptions);
}

export default function* listSaga() {
  yield all([
    watchCategoriesRequest(),
    watchCountryRequest(),
    watchSdkCategoriesRequest(),
    watchRankingsCategoriesRequest(),
    watchAppPermissionsOptionsRequest(),
    watchGeoOptionsRequest(),
  ]);
}
