import { connect } from 'react-redux';
import TableContainer from 'Table/Table.container';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { tableActions } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  updateColumns: columns => dispatch(tableActions.updateColumns(columns)),
  updatePageSize: pageSize => dispatch(tableActions.updatePageSize(pageSize)),
});

const mapStateToProps = ({
  explorePage: {
    resultsTable,
    searchForm,
    explore: { csvQueryId },
  },
  account: { adNetworks },
}) => ({
  isManual: true,
  showControls: true,
  showColumnDropdown: true,
  title: 'Results',
  canFetch: Object.keys(searchForm.filters).length !== 0 && !resultsTable.loading,
  adNetworks: adNetworks.adNetworks,
  searchForm,
  csvLink: csvQueryId ? `https://query.mightysignal.com/query_result/${csvQueryId}/pages/0?stream=true&formatter=csv` : null,
  ...resultsTable,
});

const mergeProps = (stateProps, dispatchProps) => {
  const {
    searchForm,
    adNetworks,
    ...other
  } = stateProps;

  return {
    ...other,
    ...dispatchProps,
    requestResults: ({ pageSize, pageNum, sort }) => {
      const pageSettings = {
        pageSize,
        pageNum,
      };
      const query = buildExploreRequest(searchForm, other.columns, pageSettings, sort, adNetworks);
      dispatchProps.requestResults(query);
    },
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(TableContainer);

export default ExploreTableContainer;
