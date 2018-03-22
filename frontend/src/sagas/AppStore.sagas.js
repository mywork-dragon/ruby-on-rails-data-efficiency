import { all, put, call, takeLatest } from 'redux-saga/effects';
import AppStoreService from 'services/appStore.service';
import * as actions from 'actions/AppStore.actions';
import { formatCategories } from 'utils/appStore.utils';

function* requestCategories () {
  try {
    const iosRes = yield call(AppStoreService().getIosCategories);
    const androidRes = yield call(AppStoreService().getAndroidCategories);
    const data = {};
    data.iosCategoriesById = formatCategories(iosRes.data);
    data.androidCategoriesById = formatCategories(androidRes.data);
    yield put(actions.categories.success(data));
  } catch (err) {
    console.log(err);
    yield put(actions.categories.failure());
  }
}

function* requestAvailableCountries () {
  try {
    const { data: { results } } = yield call(AppStoreService().getCountryAutocompleteResults, 1, '');
    yield put(actions.availableCountries.success(results));
  } catch (err) {
    console.log(err);
    yield put(actions.availableCountries.failure());
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
    yield put(actions.sdkCategories.failure());
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

export default function* listSaga() {
  yield all([
    watchCategoriesRequest(),
    watchCountryRequest(),
    watchSdkCategoriesRequest(),
  ]);
}
