import Bugsnag from 'bugsnag-js';
import { all, takeEvery } from 'redux-saga/effects';
import { getUserIdFromToken } from 'utils/auth.utils';
import {
  AD_NETWORKS,
  DELETE_SAVED_SEARCH,
  GET_SAVED_SEARCHES,
  LOAD_SAVED_SEARCH,
  SAVE_NEW_SEARCH,
  LOAD_PERMISSIONS,
  UPDATE_SAVED_SEARCH,
} from 'actions/Account.actions';

import {
  AVAILABLE_COUNTRIES,
  CATEGORIES,
  SDK_CATEGORIES,
  RANKINGS_COUNTRIES,
  APP_PERMISSIONS_OPTIONS,
  GEO_OPTIONS,
} from 'actions/AppStore.actions';

import {
  GET_CSV_QUERY_ID,
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
} from 'containers/ExplorePage/redux/Explore.actions';

import {
  RANKINGS_CHART,
} from 'containers/AppPage/components/rankings-tab/redux/RankingsTab.actions';

function sendToBugsnag ({ type, payload: { error } }) {
  Bugsnag.notifyException(error, {
    user_id: getUserIdFromToken(),
    action_type: type,
  });
}

function* watchError() {
  yield takeEvery([
    AD_NETWORKS.FAILURE,
    AVAILABLE_COUNTRIES.FAILURE,
    CATEGORIES.FAILURE,
    DELETE_SAVED_SEARCH.FAILURE,
    GET_CSV_QUERY_ID.FAILURE,
    GET_SAVED_SEARCHES.FAILURE,
    LOAD_SAVED_SEARCH.FAILURE,
    POPULATE_FROM_QUERY_ID.FAILURE,
    SAVE_NEW_SEARCH.FAILURE,
    SDK_CATEGORIES.FAILURE,
    TABLE_TYPES.ALL_ITEMS.FAILURE,
    LOAD_PERMISSIONS.FAILURE,
    UPDATE_SAVED_SEARCH.FAILURE,
    RANKINGS_COUNTRIES.FAILURE,
    APP_PERMISSIONS_OPTIONS.FAILURE,
    GEO_OPTIONS.FAILURE,
    RANKINGS_CHART.FAILURE,
  ], sendToBugsnag);
}

export default function* bugsnagSaga() {
  yield all([
    watchError(),
  ]);
}
