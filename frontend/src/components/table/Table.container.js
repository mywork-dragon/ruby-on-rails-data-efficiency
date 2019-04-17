import { connect } from 'react-redux';
import Table from './Table.component';
import { updateDefaultPageSize, getPublishersContactsExportCsv } from './redux/Table.actions';

const mapDispatchToProps = dispatch => ({
  updateDefaultPageSize: pageSize => dispatch(updateDefaultPageSize(pageSize)),
  onCsvExportContacts: id => dispatch(getPublishersContactsExportCsv(id)),
});

const TableContainer = connect(
  null,
  mapDispatchToProps,
)(Table);

export default TableContainer;
