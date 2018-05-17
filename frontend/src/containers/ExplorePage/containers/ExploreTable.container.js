import { connect } from 'react-redux';
import toastr from 'toastr';
import TableContainer from 'Table/Table.container';
import { buildExploreRequest, buildCsvLink } from 'utils/explore/queryBuilder.utils';
import { accessibleNetworks } from 'selectors/account.selectors';
import { getCategoryNameById } from 'selectors/appStore.selectors';
import { currentRankingsCountries, getCurrentSortOrder } from 'selectors/explore.selectors';
import { tableActions, requestQueryPage, trackTableSort } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleItem: (id, type) => () => dispatch(tableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(tableActions.toggleAllItems()),
  onCsvExport: () => dispatch(tableActions.csvExported()),
  trackSort: sort => dispatch(trackTableSort(sort)),
  updateColumns: (columns, type) => dispatch(tableActions.updateColumns(columns, type)),
  updatePageNum: (queryResultId, page) => dispatch(requestQueryPage(queryResultId, page)),
  updatePageSize: page => dispatch(tableActions.updatePageSize(page)),
});

const mapStateToProps = (state) => {
  const {
    explorePage: {
      resultsTable,
      searchForm,
      explore: {
        csvQueryId,
        queryResultId,
        currentLoadedQuery,
      },
    },
    account: {
      permissions,
    },
  } = state;

  return {
    isManual: true,
    showControls: true,
    showColumnDropdown: Object.entries(resultsTable.columns).some(x => x[1] !== 'LOCKED'),
    title: 'Results',
    canFetch: Object.keys(searchForm.filters).length !== 0 && !resultsTable.loading,
    adNetworks: accessibleNetworks(state),
    csvLink: buildCsvLink(csvQueryId, permissions.permissions),
    queryResultId,
    currentLoadedQuery,
    resultType: searchForm.resultType,
    ...resultsTable,
    getCategoryById: (id, platform) => getCategoryNameById(state, id, platform),
    currentRankingsCountries: currentRankingsCountries(state),
    currentSort: getCurrentSortOrder(state),
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
    resultType,
    currentColumns,
    resultsCount,
    ...other
  } = stateProps;

  const {
    trackSort,
    updatePageNum,
    updateColumns,
    updatePageSize,
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
    resultType,
    resultsCount,
    ...other,
    ...rest,
    onPageChange: page => updatePageNum(queryResultId, page),
    onPageSizeChange: (newSize) => {
      if (canFetch && resultsCount) {
        requestResults({
          pageNum: 0,
          pageSize: newSize,
          sort,
        });
      } else {
        updatePageSize(newSize);
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
    updateColumns: columns => updateColumns(columns, resultType),
    onCsvExport: () => toastr.info('Building your CSV...'),
  };
};

const ExploreTableContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(TableContainer);

export default ExploreTableContainer;
