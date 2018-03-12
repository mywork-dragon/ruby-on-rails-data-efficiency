import { connect } from 'react-redux';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { hasFilters } from 'utils/explore/general.utils';
import * as appStore from 'selectors/appStore.selectors';
import { adNetworks } from 'actions/Account.actions';
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
  getAdNetworks: () => dispatch(adNetworks.request()),
});

const mapStateToProps = (state) => {
  const { explorePage: { explore, searchForm, resultsTable }, account: { adNetworks } } = state;

  return {
    canFetch: hasFilters(searchForm.filters),
    ...explore,
    searchForm,
    resultsTable,
    iosCategories: appStore.getIosCategories(state),
    androidCategories: appStore.getAndroidCategories(state),
    availableCountries: appStore.getAvailableCountries(state),
    networkStore: adNetworks,
  };
};

const mergeProps = (storeProps, dispatchProps) => {
  const {
    searchForm,
    resultsTable:
      {
        columns,
        pageSize,
        sort,
      },
    ...rest
  } = storeProps;

  return {
    ...searchForm,
    ...dispatchProps,
    ...rest,
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
