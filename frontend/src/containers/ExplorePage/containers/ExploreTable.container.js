import { connect } from 'react-redux';
import TableContainer from 'Table/Table.container';
import { accessibleNetworks } from 'selectors/account.selectors';
import { buildExploreRequest, buildCsvLink } from 'utils/explore/queryBuilder.utils';
import { tableActions, requestQueryPage, trackTableSort, getCsv } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  trackSort: sort => dispatch(trackTableSort(sort)),
  updateColumns: columns => dispatch(tableActions.updateColumns(columns)),
  updatePageNum: (queryResultId, page) => dispatch(requestQueryPage(queryResultId, page)),
  requestCsv: params => dispatch(getCsv.request(params)),
});

const mapStateToProps = (state) => {
  const {
    explorePage: {
      resultsTable,
      searchForm,
      explore: {
        queryResultId,
        currentLoadedQuery,
        csvLoading,
      },
    },
  } = state;

  return {
    isManual: true,
    showControls: true,
    showColumnDropdown: true,
    title: 'Results',
    canFetch: Object.keys(searchForm.filters).length !== 0 && !resultsTable.loading,
    adNetworks: accessibleNetworks(state),
    resultType: searchForm.resultType,
    csvLoading,
    queryResultId,
    currentLoadedQuery,
    ...resultsTable,
  };
};

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
    requestCsv,
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
    onCsvExport: () => requestCsv({ form: currentLoadedQuery, sort }),
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(TableContainer);

export default ExploreTableContainer;
