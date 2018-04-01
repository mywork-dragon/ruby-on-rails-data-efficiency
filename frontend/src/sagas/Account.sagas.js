import { all, put, call, takeLatest, takeEvery } from 'redux-saga/effects';
import toastr from 'toastr';
import AccountService from 'services/account.service';
import SavedSearchService from 'services/savedSearch.service';
import ExploreService from 'services/explore.service';
import { isCurrentQuery } from 'utils/explore/general.utils';
import { populateFromQueryId } from 'containers/ExplorePage/redux/Explore.actions';
import {
  AD_NETWORKS,
  GET_SAVED_SEARCHES,
  SAVE_NEW_SEARCH,
  DELETE_SAVED_SEARCH,
  adNetworks,
  getSavedSearches,
  saveNewSearch,
  deleteSavedSearch,
} from 'actions/Account.actions';

function* requestAdNetworks () {
  try {
    const res = yield call(AccountService().getAdNetworks);
    yield put(adNetworks.success(res.data));
  } catch (error) {
    console.log(error);
    yield put(adNetworks.failure());
    throw error;
  }
}

function* requestSavedSearches () {
  try {
    const { data } = yield call(SavedSearchService().getSavedSearches);
    const v2Searches = data.filter(x => x.version === 'v2');
    const searches = {};
    for (let i = 0; i < v2Searches.length; i++) {
      const search = v2Searches[i];
      search.queryId = search.search_params;
      delete search.search_params;
      const { data: { formState } } = yield call(ExploreService.getQueryParams, search.queryId);
      search.formState = formState;
      searches[search.id] = search;
    }
    yield put(getSavedSearches.success(searches));
  } catch (error) {
    console.log(error);
    yield put(getSavedSearches.failure());
    throw error;
  }
}

function* createSavedSearch (action) {
  const { name, params } = action.payload;
  const { data: { query_id } } = yield call(ExploreService.getQueryId, params);
  try {
    const res = yield call(SavedSearchService().createSavedSearch, name, query_id);
    toastr.success('Search saved successfully!');
    const newSearch = { ...res.data, formState: params.formState };
    yield put(saveNewSearch.success(newSearch));
    if (!isCurrentQuery(query_id)) {
      yield put(populateFromQueryId.request(query_id));
    }
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem saving your search.");
    throw error;
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
    throw error;
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

export default function* accountSaga() {
  yield all([
    watchAdNetworkFetch(),
    watchSavedSearchRequest(),
    watchNewSavedSearchRequest(),
    watchSavedSearchDelete(),
  ]);
}
