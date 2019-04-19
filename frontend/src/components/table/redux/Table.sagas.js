import { all, takeLatest, select, call, put } from 'redux-saga/effects';
import { setPreferredPageSize } from 'utils/table.utils';
import { currentQueryId } from 'selectors/explore.selectors';
import { buildContactsExportCsvRequest } from 'utils/explore/queryBuilder.utils';
import service from 'services/mightyQuery.service';
import publisherService from 'services/publisher.service';

import {
  UPDATE_DEFAULT_PAGE_SIZE,
  PUBLISHERS_CONTACTS_CSV_EXPORT_START,
  PUBLISHERS_CONTACTS_CSV_EXPORT_FINISH,
} from './Table.actions';


function updatePageSize ({ payload: { pageSize } }) {
  setPreferredPageSize(pageSize);
}

function* watchPageSizeUpdate() {
  yield takeLatest(UPDATE_DEFAULT_PAGE_SIZE, updatePageSize);
}

export default function* tableSaga() {
  yield all([
    watchPageSizeUpdate(),
    requestPublisherContactsCsv(),
  ]);
}


function formatDomains(data) {
  return Object.values(data).flat(2).map(domainsHash => domainsHash.domains).flat(2);
}

function downloadCsv(content, name) {
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
  hiddenElement.target = '_blank';
  hiddenElement.download = name + '.csv';
  hiddenElement.click();
}


function* getPublishersContactsExportStatus({payload}) {
  try {
    const current_query_id = yield select(currentQueryId);
    const current_query_params = yield call(service.getQueryParams, current_query_id);
    const csvParams = buildContactsExportCsvRequest();
    let new_query_params = current_query_params.data;
    new_query_params.select = csvParams.select;
    new_query_params.page_settings = csvParams.page_settings;
    const { data: { query_id } } = yield call(service.getQueryId, new_query_params);
    const queryInfo = yield call(service.getQueryResultInfo, query_id);
    const { query_result_id } = queryInfo.data;
    const { data: {pages} } = yield call(service.getResultsByResultId, query_result_id, 0);
    const domains = yield call(formatDomains, pages);
    const res = yield call(publisherService().getContactsExportCsv, domains);
    yield call(downloadCsv, res.data, 'contacts');
    yield put({ type: PUBLISHERS_CONTACTS_CSV_EXPORT_FINISH });
  } catch (error) {
    yield call(console.log, error);
  }
}


function* requestPublisherContactsCsv () {
  yield takeLatest(PUBLISHERS_CONTACTS_CSV_EXPORT_START, getPublishersContactsExportStatus);
}
