import { connect } from 'react-redux';
import Table from 'Table/Table.component';
import { tableActions } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  updateColumns: columns => dispatch(tableActions.updateColumns(columns)),
});

const mapStateToProps = ({ explorePage: { resultsTable } }) => ({
  isManual: true,
  ...resultsTable,
  showControls: true,
  showColumnDropdown: true,
  title: 'Results',
});

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Table);

export default ExploreTableContainer;
