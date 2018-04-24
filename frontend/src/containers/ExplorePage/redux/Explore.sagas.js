import { all, put, call, takeLatest, select } from 'redux-saga/effects';
import service from 'services/explore.service';
import { formatResults, setExploreColumns, isCurrentQuery } from 'utils/explore/general.utils';
import { downloadCsv } from 'utils/table.utils';
import { isFacebookOnly, accessibleNetworks, getPermissions } from 'selectors/account.selectors';
import { currentFormVersion, getCurrentState } from 'selectors/explore.selectors';
import { buildCsvRequest, buildExploreRequest, buildCsvLink } from 'utils/explore/queryBuilder.utils';
import validateFormState from 'utils/explore/formStateValidation.utils';
import toastr from 'toastr';
import {
  LOAD_SAVED_SEARCH,
  loadSavedSearch,
  updateSavedSearch,
} from 'actions/Account.actions';

import {
  POPULATE_FROM_QUERY_ID,
  TABLE_TYPES,
  REQUEST_QUERY_PAGE,
  GET_CSV,
  populateFromQueryId,
  tableActions,
  updateQueryId,
  updateQueryResultId,
  getCsv,
} from './Explore.actions';

function* requestResults ({ payload }) {
  const { params, params: { page_settings: { page: pageNum } } } = payload;
  delete params.page_settings.page;
  try {
    const { data: { query_id } } = yield call(service.getQueryId, params);
    yield put(tableActions.clearResults());
    history.pushState(null, null, `#/search/v2/${query_id}`);
    yield call(requestResultsByQueryId, query_id, params, pageNum);
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure(error));
  }
}

function* populateFromQuery ({ payload: { id, searchId } }) {
  try {
    let { data: params, data: { formState } } = yield call(service.getQueryParams, id);
    const formVersion = yield select(currentFormVersion);
    const validatedForm = validateFormState(JSON.parse(formState), formVersion);
    if (validatedForm.shouldUpdate) {
      const { query_id: newId, params: newParams } = yield call(getQueryIdFromState, validatedForm);
      if (newId !== id) {
        formState = newParams.formState;
        params = newParams;
        if (searchId) {
          yield put(updateSavedSearch.request(searchId, { queryId: newId, formState }));
          id = newId;
        }
      }
    }
    yield put(populateFromQueryId.success(id, validatedForm.form));
    yield put(tableActions.setLoading(true));
    if (searchId) {
      yield put(loadSavedSearch.success(searchId));
    }
    yield call(requestResultsByQueryId, id, params, 0);
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem loading the query.");
    yield put(populateFromQueryId.failure(error));
    yield put(tableActions.allItems.failure(error));
  }
}

function* requestResultsByQueryId (id, params, pageNum) {
  if (!isCurrentQuery(id)) {
    history.pushState(null, null, `#/search/v2/${id}`);
  }
  try {
    yield put(updateQueryId(id, JSON.parse(params.formState)));
    const res = yield call(service.getQueryResultInfo, id);
    // this failure doesn't get caught
    const { number_results, query_result_id } = res.data;
    yield put(updateQueryResultId(query_result_id));
    if (number_results === 0) {
      yield put(tableActions.allItems.success({ resultsCount: 0 }));
    } else {
      const { data } = yield call(service.getResultsByResultId, query_result_id, pageNum);
      const items = formatResults(data, params, number_results);
      yield put(tableActions.allItems.success(items));
    }
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure());
  }
}

function* requestResultsByQueryResultId ({ payload: { id, page } }) {
  try {
    yield put(tableActions.setLoading(true));
    const { data } = yield call(service.getResultsByResultId, id, page);
    const items = formatResults(data);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure(error));
  }
}

function* getQueryIdFromState ({ form }) {
  try {
    const { resultsTable } = yield select(getCurrentState);
    const accountNetworks = yield select(accessibleNetworks);
    const pageSettings = { pageSize: resultsTable.pageSize, pageNum: 0 };
    const params = buildExploreRequest(form, resultsTable.columns, pageSettings, resultsTable.sort, accountNetworks);
    const { data: { query_id } } = yield call(service.getQueryId, params);
    return { query_id, params };
  } catch (error) {
    console.log(error);
    yield put(tableActions.allItems.failure(error));
  }
}

function* requestCsv ({ payload: { params } }) {
  try {
    const facebookOnly = yield select(isFacebookOnly);
    const csvParams = buildCsvRequest(params, facebookOnly);
    const { data: { query_id } } = yield call(service.getQueryId, csvParams);
    const { data: { query_result_id, number_pages } } = yield call(service.getQueryResultInfo, query_id);
    const permissions = yield select(getPermissions);
    const url = buildCsvLink(query_result_id, number_pages, permissions);
    downloadCsv(url);
    yield put(getCsv.success());
  } catch (error) {
    console.log(error);
    yield put(getCsv.failure());
  }
}

function updateExploreTableColumns ({ payload: { columns } }) {
  setExploreColumns(columns);
}

function* watchResultsRequest() {
  yield takeLatest(TABLE_TYPES.ALL_ITEMS.REQUEST, requestResults);
}

function* watchQueryPopulation() {
  yield takeLatest(POPULATE_FROM_QUERY_ID.REQUEST, populateFromQuery);
}

function* watchSavedSearchLoad() {
  yield takeLatest(LOAD_SAVED_SEARCH.REQUEST, populateFromQuery);
}

function* watchColumnUpdate() {
  yield takeLatest(TABLE_TYPES.UPDATE_COLUMNS, updateExploreTableColumns);
}

function* watchPageChange() {
  yield takeLatest(REQUEST_QUERY_PAGE, requestResultsByQueryResultId);
}

function* watchCsvRequest() {
  yield takeLatest(GET_CSV.REQUEST, requestCsv);
}

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
    watchSavedSearchLoad(),
    watchColumnUpdate(),
    watchPageChange(),
    watchCsvRequest(),
  ]);
}
