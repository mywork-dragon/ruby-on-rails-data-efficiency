import Bugsnag from 'bugsnag-js';
import { all, takeEvery } from 'redux-saga/effects';
import jwt from 'jsonwebtoken';

import {
  AD_NETWORKS,
  DELETE_SAVED_SEARCH,
  GET_SAVED_SEARCHES,
  LOAD_SAVED_SEARCH,
  SAVE_NEW_SEARCH,
} from 'actions/Account.actions';

import {
  AVAILABLE_COUNTRIES,
  CATEGORIES,
  SDK_CATEGORIES,
} from 'actions/AppStore.actions';

import {
  GET_CSV_QUERY_ID,
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
} from 'containers/ExplorePage/redux/Explore.actions';

function sendToBugsnag ({ payload: { error } }) {
  Bugsnag.notifyException(error, { user_id: jwt.decode(localStorage.getItem('ms_jwt_auth_token')).user_id });
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
  ], sendToBugsnag);
}

export default function* bugsnagSaga() {
  yield all([
    watchError(),
  ]);
}
