import { connect } from 'react-redux';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import SearchForm from '../components/SearchForm.component';
import { tableActions, toggleForm, updateActivePanel } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  clearFilters: () => () => dispatch(tableActions.clearFilters()),
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  toggleForm: () => dispatch(toggleForm()),
  updateActivePanel: index => dispatch(updateActivePanel(index)),
  updateFilter: (parameter, value) => () => dispatch(tableActions.updateFilter(parameter, value)),
});

const mapStateToProps = ({ explorePage: { explore, searchForm, resultsTable } }) => ({
  canFetch: Object.keys(searchForm.filters).length !== 0,
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
      dispatchProps.requestResults(query);
    },
  };
};

const SearchFormContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(SearchForm);

export default SearchFormContainer;
