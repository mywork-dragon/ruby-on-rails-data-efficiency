import { connect } from 'react-redux';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { hasFilters } from 'utils/explore/general.utils';
import SearchForm from '../components/SearchForm.component';
import {
  tableActions,
  toggleForm,
  togglePanel,
  addBlankSdkFilter,
  duplicateSdkFilter,
} from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  addSdkFilter: () => dispatch(addBlankSdkFilter()),
  clearFilters: () => () => dispatch(tableActions.clearFilters()),
  deleteFilter: (filterKey, index) => dispatch(tableActions.deleteFilter(filterKey, index)),
  duplicateSdkFilter: index => () => dispatch(duplicateSdkFilter(index)),
  getResults: params => dispatch(tableActions.allItems.request(params)),
  toggleForm: () => dispatch(toggleForm()),
  togglePanel: index => () => dispatch(togglePanel(index)),
  updateFilter: (parameter, value, options) => () => dispatch(tableActions.updateFilter(parameter, value, options)),
});

const mapStateToProps = ({ explorePage: { explore, searchForm, resultsTable } }) => ({
  canFetch: hasFilters(searchForm.filters),
  explore,
  searchForm,
  resultsTable,
});

const mergeProps = (storeProps, dispatchProps) => {
  const {
    canFetch,
    explore,
    searchForm,
    resultsTable:
      {
        columns,
        pageSize,
        sort,
      },
  } = storeProps;

  return {
    canFetch,
    ...explore,
    ...searchForm,
    ...dispatchProps,
    requestResults: () => () => {
      const pageSettings = { pageSize, pageNum: 0 };
      const query = buildExploreRequest(searchForm, columns, pageSettings, sort);
      dispatchProps.getResults(query);
    },
  };
};

const SearchFormContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(SearchForm);

export default SearchFormContainer;
