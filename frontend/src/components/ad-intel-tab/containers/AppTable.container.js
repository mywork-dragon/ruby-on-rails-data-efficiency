import { connect } from 'react-redux';
import Table from 'Table/Table.component';
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
)(Table);

export default AppTableContainer;
