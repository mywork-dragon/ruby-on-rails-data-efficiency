import { all, put, call, takeLatest } from 'redux-saga/effects';
import AppStoreService from 'services/appStore.service';
import * as actions from 'actions/AppStore.actions';
import { formatCategories } from 'utils/appStore.utils';
// import { iosCategories, androidCategories } from 'utils/mocks/mock-categories.utils';

function* requestCategories () {
  try {
    const iosRes = yield call(AppStoreService().getIosCategories);
    const androidRes = yield call(AppStoreService().getAndroidCategories);
    const data = {};
    data.iosCategoriesById = formatCategories(iosRes.data);
    data.androidCategoriesById = formatCategories(androidRes.data);
    // data.iosCategoriesById = formatCategories(iosCategories);
    // data.androidCategoriesById = formatCategories(androidCategories);
    yield put(actions.categories.success(data));
  } catch (err) {
    console.log(err);
    yield put(actions.categories.failure);
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

function* watchCategoriesRequest() {
  yield takeLatest(actions.CATEGORIES.REQUEST, requestCategories);
}

function* watchCountryRequest() {
  yield takeLatest(actions.AVAILABLE_COUNTRIES.REQUEST, requestAvailableCountries);
}

export default function* listSaga() {
  yield all([
    watchCategoriesRequest(),
    watchCountryRequest(),
  ]);
}
