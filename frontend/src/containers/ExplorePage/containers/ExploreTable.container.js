import { connect } from 'react-redux';
import TableContainer from 'Table/Table.container';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { $localStorage } from 'utils/localStorage.utils';
import { tableActions, requestQueryPage, trackTableSort } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  onCsvExport: () => dispatch(tableActions.csvExported()),
  trackSort: sort => dispatch(trackTableSort(sort)),
  updateColumns: columns => dispatch(tableActions.updateColumns(columns)),
  updatePageNum: (queryResultId, page) => dispatch(requestQueryPage(queryResultId, page)),
});

const mapStateToProps = ({
  explorePage: {
    resultsTable,
    searchForm,
    explore: {
      csvQueryId,
      queryResultId,
      currentLoadedQuery,
    },
  },
  account: { adNetworks },
}) => ({
  isManual: true,
  showControls: true,
  showColumnDropdown: true,
  title: 'Results',
  canFetch: Object.keys(searchForm.filters).length !== 0 && !resultsTable.loading,
  adNetworks: adNetworks.adNetworks,
  csvLink: csvQueryId ? `https://query.mightysignal.com/query_result/${csvQueryId}/pages/0?stream=true&formatter=csv&JWT=${$localStorage.get('queryToken')}` : null,
  queryResultId,
  currentLoadedQuery,
  ...resultsTable,
});

const mergeProps = (stateProps, dispatchProps) => {
  const {
    adNetworks,
    canFetch,
    pageSize,
    sort,
    pageNum,
    queryResultId,
    currentLoadedQuery,
    ...other
  } = stateProps;

  const {
    trackSort,
    updatePageNum,
    ...rest
  } = dispatchProps;

  const requestResults = ({ pageSize: size, pageNum: page, sort: currentSort }) => {
    const pageSettings = {
      pageSize: size,
      pageNum: page,
    };
    const query = buildExploreRequest(currentLoadedQuery, other.columns, pageSettings, currentSort, adNetworks);
    dispatchProps.requestResults(query);
  };

  return {
    canFetch,
    pageSize,
    sort,
    pageNum,
    ...other,
    ...rest,
    onPageChange: page => updatePageNum(queryResultId, page),
    onPageSizeChange: (newSize) => {
      if (canFetch) {
        requestResults({
          pageNum: 0,
          pageSize: newSize,
          sort,
        });
      }
    },
    onSortedChange: (newSort) => {
      trackSort(newSort);
      if (canFetch) {
        requestResults({
          pageNum: 0,
          pageSize,
          sort: newSort,
        });
      }
    },
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(TableContainer);

export default ExploreTableContainer;
