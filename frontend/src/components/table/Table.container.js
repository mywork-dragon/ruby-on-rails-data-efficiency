import { connect } from 'react-redux';
import Table from './Table.component';
import { updatePageSize } from './redux/Table.actions';

const mapDispatchToProps = dispatch => ({
  updatePageSize: pageSize => dispatch(updatePageSize(pageSize)),
});

const TableContainer = connect(
  null,
  mapDispatchToProps,
)(Table);

export default TableContainer;
