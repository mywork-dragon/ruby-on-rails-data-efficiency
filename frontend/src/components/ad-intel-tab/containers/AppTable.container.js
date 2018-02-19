import { connect } from 'react-redux';
import TableContainer from 'Table/Table.container';
import { pubAdIntelTableActions } from 'containers/PublisherPage/redux/Publisher.actions';

const mapDispatchToProps = dispatch => ({
  toggleItem: (id, type) => () => dispatch(pubAdIntelTableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(pubAdIntelTableActions.toggleAllItems()),
});

const mapStateToProps = ({ publisherPage: { adIntelligence: { appTable } } }, { title }) => ({
  title,
  ...appTable,
  isAdIntel: true,
});

const AppTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(TableContainer);

export default AppTableContainer;
