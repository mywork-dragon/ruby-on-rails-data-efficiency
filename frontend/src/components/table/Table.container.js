import { connect } from 'react-redux';
import Table from './Table.component';
import { updateDefaultPageSize } from './redux/Table.actions';

const mapDispatchToProps = dispatch => ({
  updateDefaultPageSize: pageSize => dispatch(updateDefaultPageSize(pageSize)),
});

const TableContainer = connect(
  null,
  mapDispatchToProps,
)(Table);

export default TableContainer;
