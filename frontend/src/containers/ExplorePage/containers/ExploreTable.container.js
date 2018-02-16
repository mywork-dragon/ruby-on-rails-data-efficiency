import { connect } from 'react-redux';
import Table from 'Table/Table.component';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { tableActions } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  updateColumns: columns => dispatch(tableActions.updateColumns(columns)),
});

const mapStateToProps = ({ explorePage: { resultsTable, searchForm } }) => ({
  isManual: true,
  showControls: true,
  showColumnDropdown: true,
  title: 'Results',
  searchForm,
  ...resultsTable,
});

const mergeProps = (stateProps, dispatchProps) => {
  const { searchForm, ...other } = stateProps;
  return {
    ...other,
    ...dispatchProps,
    requestResults: ({ pageSize, pageNum, sort }) => {
      const pageSettings = {
        pageSize,
        pageNum,
      };
      const query = buildExploreRequest(searchForm, other.columns, pageSettings, sort);
      dispatchProps.requestResults(query);
    },
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(Table);

export default ExploreTableContainer;
