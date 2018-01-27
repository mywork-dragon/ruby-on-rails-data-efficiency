import { connect } from 'react-redux';
import { exploreResults } from 'utils/mock-data.utils';
import Table from 'Table/Table.component';
import { exploreTableActions } from '../redux/Explore.actions';


const mapDispatchToProps = dispatch => ({
  loadMockData: () => dispatch(exploreTableActions.loadResults(exploreResults.results)),
  toggleItem: (id, type) => dispatch(exploreTableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(exploreTableActions.toggleAllItems()),
});

const mapStateToProps = (store) => {
  const {
    activeColumns,
    sort,
  } = store.explore.tableOptions;

  const {
    results,
    selectedItems,
  } = store.explore.resultsTable;

  return {
    headers: activeColumns,
    sort,
    results,
    selectedItems,
    showControls: true,
    title: 'Results',
    totalCount: results.length,
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Table);

export default ExploreTableContainer;
