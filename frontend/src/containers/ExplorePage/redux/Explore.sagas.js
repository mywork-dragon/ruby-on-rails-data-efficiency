import { all, put, call, fork, takeLatest, select } from 'redux-saga/effects';
import service from 'services/mightyQuery.service';
import { formatResults, setExploreColumns, isCurrentQuery } from 'utils/explore/general.utils';
import { isFacebookOnly, accessibleNetworks } from 'selectors/account.selectors';
import { getIosCategories, getAndroidCategories } from 'selectors/appStore.selectors';
import { currentFormVersion, getCurrentState, getCurrentColumns, getCurrentResultType } from 'selectors/explore.selectors';
import { buildCsvRequest, buildExploreRequest } from 'utils/explore/queryBuilder.utils';
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
  populateFromQueryId,
  tableActions,
  updateQueryId,
  updateQueryResultId,
  getCsvQueryId,
} from './Explore.actions';

function* requestResults ({ payload }) {
  const { params, params: { page_settings: { page: pageNum } } } = payload;
  delete params.page_settings.page;
  try {
    const { data: { query_id } } = yield call(service.getQueryId, params);
    yield put(tableActions.clearResults());
    window.location.href = `#/search/v2/${query_id}`;
    const { searchForm } = yield select(getCurrentState);
    yield fork(requestCsvQueryId, params, searchForm);
    yield call(requestResultsByQueryId, query_id, params, pageNum);
  } catch (error) {
    console.log(error);
    const currentColumns = yield select(getCurrentColumns);
    yield put(tableActions.allItems.failure(error, { columns: currentColumns }));
  }
}

function* populateFromQuery ({ payload: { id, searchId } }) {
  try {
    let { data: params, data: { formState } } = yield call(service.getQueryParams, id);
    const formVersion = yield select(currentFormVersion);
    const iosCategories = yield select(getIosCategories);
    const androidCategories = yield select(getAndroidCategories);
    const validatedForm = validateFormState(JSON.parse(formState), formVersion, iosCategories, androidCategories);
    if (validatedForm.shouldUpdate) {
      const { query_id: newId, params: newParams } = yield call(getQueryIdFromState, validatedForm);
      if (newId !== id) {
        formState = newParams.formState;
        params = newParams;
        id = newId;
        if (searchId) {
          yield put(updateSavedSearch.request(searchId, { queryId: newId, formState }));
        }
      }
    }
    yield put(populateFromQueryId.success(id, validatedForm.form));
    yield put(tableActions.setLoading(true));
    if (searchId) {
      yield put(loadSavedSearch.success(searchId));
    }
    yield call(requestResultsByQueryId, id, params, 0);
    yield fork(requestCsvQueryId, params, validatedForm.form);
  } catch (error) {
    console.log(error);
    toastr.error("We're sorry, there was a problem loading the query.");
    const columns = yield select(getCurrentColumns);
    yield put(populateFromQueryId.failure(error));
    yield put(tableActions.allItems.failure(error, { columns }));
  }
}

function* requestCsvQueryId (params, form) {
  try {
    yield put(getCsvQueryId.request());
    const facebookOnly = yield select(isFacebookOnly);
    const csvParams = buildCsvRequest(params, facebookOnly, form);
    const { data: { query_id } } = yield call(service.getQueryId, csvParams);
    yield put(getCsvQueryId.success(query_id));
  } catch (error) {
    console.log(error);
    yield put(getCsvQueryId.failure(error));
  }
}

function* requestResultsByQueryId (id, params, pageNum) {
  if (!isCurrentQuery(id)) {
    window.location.href = `#/search/v2/${id}`;
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
      const resultType = yield select(getCurrentResultType);
      const items = formatResults(data, resultType, params, number_results);
      items.columns = yield select(getCurrentColumns);
      yield put(tableActions.allItems.success(items));
    }
  } catch (error) {
    console.log(error);
    const columns = yield select(getCurrentColumns);
    yield put(tableActions.allItems.failure(error, { columns }));
  }
}

function* requestResultsByQueryResultId ({ payload: { id, page } }) {
  try {
    yield put(tableActions.setLoading(true));
    const { data } = yield call(service.getResultsByResultId, id, page);
    const resultType = yield select(getCurrentResultType);
    const items = formatResults(data, resultType);
    items.columns = yield select(getCurrentColumns);
    yield put(tableActions.allItems.success(items));
  } catch (error) {
    console.log(error);
    const columns = yield select(getCurrentColumns);
    yield put(tableActions.allItems.failure(error, { columns }));
  }
}

function* getQueryIdFromState ({ form }) {
  try {
    const { resultsTable } = yield select(getCurrentState);
    const columns = yield select(getCurrentColumns, form.resultType);
    const accountNetworks = yield select(accessibleNetworks);
    const pageSettings = { pageSize: resultsTable.pageSize };
    const params = buildExploreRequest(form, columns, pageSettings, resultsTable.sort, accountNetworks);
    const { data: { query_id } } = yield call(service.getQueryId, params);
    return { query_id, params };
  } catch (error) {
    console.log(error);
    const columns = yield select(getCurrentColumns);
    yield put(tableActions.allItems.failure(error, { columns }));
  }
}

function updateExploreTableColumns ({ payload: { columns, type } }) {
  setExploreColumns(type, columns);
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

export default function* exploreSaga() {
  yield all([
    watchResultsRequest(),
    watchQueryPopulation(),
    watchSavedSearchLoad(),
    watchColumnUpdate(),
    watchPageChange(),
  ]);
}
