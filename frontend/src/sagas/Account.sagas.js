import { all, put, call, takeLatest, takeEvery } from 'redux-saga/effects';
import toastr from 'toastr';
import AccountService from 'services/account.service';
import SavedSearchService from 'services/savedSearch.service';
import MightyQueryService from 'services/mightyQuery.service';
import { isCurrentQuery } from 'utils/explore/general.utils';
import { formatSavedSearches } from 'utils/account.utils';
import { populateFromQueryId } from 'containers/ExplorePage/redux/Explore.actions';
import {
  AD_NETWORKS,
  GET_SAVED_SEARCHES,
  SAVE_NEW_SEARCH,
  DELETE_SAVED_SEARCH,
  UPDATE_SAVED_SEARCH,
  adNetworks,
  getSavedSearches,
  saveNewSearch,
  deleteSavedSearch,
  updateSavedSearch,
  LOAD_PERMISSIONS,
  loadPermissions,
} from 'actions/Account.actions';

function* requestAdNetworks () {
  try {
    const res = yield call(AccountService().getAdNetworks);
    yield put(adNetworks.success(res.data));
  } catch (error) {
    console.log(error);
    yield put(adNetworks.failure(error));
  }
}

function* requestSavedSearches () {
  try {
    const { data } = yield call(SavedSearchService().getSavedSearches);
    const v2Searches = data.filter(x => x.version === 'v2');
    const queries = yield all(v2Searches.map(search => call(MightyQueryService.getQueryParams, search.search_params)));
    const searches = formatSavedSearches(v2Searches, queries);
    yield put(getSavedSearches.success(searches));
  } catch (error) {
    console.log(error);
    yield put(getSavedSearches.failure(error));
  }
}

function* createSavedSearch (action) {
  const { name, params } = action.payload;
  try {
    const { data: { query_id } } = yield call(MightyQueryService.getQueryId, params);
    const res = yield call(SavedSearchService().createSavedSearch, name, query_id);
    toastr.success('Search saved successfully!');
    const newSearch = { ...res.data, queryId: res.data.search_params, formState: params.formState };
    yield put(saveNewSearch.success(newSearch));
    if (!isCurrentQuery(query_id)) {
      yield put(populateFromQueryId.request(query_id));
    }
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem saving your search.");
    yield put(saveNewSearch.failure(error));
  }
}

function* savedSearchUpdate (action) {
  const { id, params: { queryId, formState } } = action.payload;
  try {
    const { data } = yield call(SavedSearchService().updateSavedSearch, id, queryId);
    const newSearch = { ...data, queryId: data.search_params, formState };
    yield put(updateSavedSearch.success(newSearch));
  } catch (error) {
    console.log(error);
    yield put(updateSavedSearch.failure(error));
  }
}

function* requestPermissions (action) {
  try {
    const response = yield call(AccountService().getPermissions);
    yield put(loadPermissions.success(response.data))
  } catch (error) {
    console.log(error);
    yield put(loadPermissions.failure(error));
  }
}

function* handleSavedSearchDelete (action) {
  const { id } = action.payload;
  try {
    yield call(SavedSearchService().deleteSavedSearch, id);
    toastr.success('Search deleted successfully.');
    yield put(deleteSavedSearch.success(id));
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem deleting your search.");
    yield put(deleteSavedSearch.failure(error));
  }
}

function* watchAdNetworkFetch() {
  yield takeLatest(AD_NETWORKS.REQUEST, requestAdNetworks);
}

function* watchSavedSearchRequest() {
  yield takeLatest(GET_SAVED_SEARCHES.REQUEST, requestSavedSearches);
}

function* watchNewSavedSearchRequest() {
  yield takeLatest(SAVE_NEW_SEARCH.REQUEST, createSavedSearch);
}

function* watchSavedSearchDelete() {
  yield takeEvery(DELETE_SAVED_SEARCH.REQUEST, handleSavedSearchDelete);
}


function* watchLoadPermissions() {
  yield takeLatest(LOAD_PERMISSIONS.REQUEST, requestPermissions);
}

function* watchSavedSearchUpdate() {
  yield takeLatest(UPDATE_SAVED_SEARCH.REQUEST, savedSearchUpdate);
}

export default function* accountSaga() {
  yield all([
    watchAdNetworkFetch(),
    watchSavedSearchRequest(),
    watchNewSavedSearchRequest(),
    watchSavedSearchDelete(),
    watchLoadPermissions(),
    watchSavedSearchUpdate(),
  ]);
}
