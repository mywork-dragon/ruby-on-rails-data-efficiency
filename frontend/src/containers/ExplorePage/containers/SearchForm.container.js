import { connect } from 'react-redux';
import { buildExploreRequest } from 'utils/explore/queryBuilder.utils';
import { hasFilters } from 'utils/explore/general.utils';
import * as appStore from 'selectors/appStore.selectors';
import { getCurrentColumns } from 'selectors/explore.selectors';
import { adNetworks, saveNewSearch } from 'actions/Account.actions';
import * as account from 'selectors/account.selectors';
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
  toggleForm: type => dispatch(toggleForm(type)),
  togglePanel: index => () => dispatch(togglePanel(index)),
  updateFilter: (parameter, value, options) => () => dispatch(tableActions.updateFilter(parameter, value, options)),
  getAdNetworks: () => dispatch(adNetworks.request()),
  saveSearch: (name, params) => dispatch(saveNewSearch.request(name, params)),
});

const mapStateToProps = (state) => {
  const { explorePage: { explore, searchForm, resultsTable } } = state;

  return {
    canFetch: hasFilters(searchForm.filters) && !resultsTable.loading,
    ...explore,
    searchForm,
    resultsTable,
    columns: getCurrentColumns(state),
    iosCategories: appStore.getIosCategories(state),
    androidCategories: appStore.getAndroidCategories(state),
    availableCountries: appStore.getAvailableCountries(state),
    iosSdkCategories: appStore.getIosSdkCategories(state),
    androidSdkCategories: appStore.getAndroidSdkCategories(state),
    adNetworks: account.accessibleNetworks(state),
    shouldFetchAdNetworks: account.shouldFetchAdNetworks(state),
    facebookOnly: account.isFacebookOnly(state),
    rankingsCountries: appStore.getRankingsCountries(state),
    appPermissionsOptions: appStore.getAppPermissionsOptions(state),
    canAccessAppPermissions: account.canAccessFeature(state, 'app-permissions-filter'),
  };
};

const mergeProps = (storeProps, dispatchProps) => {
  const {
    searchForm,
    resultsTable:
      {
        pageSize,
        sort,
        loading,
      },
    adNetworks: accountNetworks,
    columns,
    ...rest
  } = storeProps;

  const { getResults, saveSearch, ...other } = dispatchProps;

  return {
    adNetworks: accountNetworks,
    ...searchForm,
    ...other,
    loading,
    ...rest,
    requestResults: () => {
      const pageSettings = { pageSize, pageNum: 0 };
      const query = buildExploreRequest(searchForm, columns, pageSettings, sort, accountNetworks);
      getResults(query);
    },
    saveSearch: (name) => {
      const pageSettings = { pageSize, pageNum: 0 };
      const query = buildExploreRequest(searchForm, columns, pageSettings, sort, accountNetworks);
      saveSearch(name, query);
      getResults(query);
    },
  };
};

const SearchFormContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(SearchForm);

export default SearchFormContainer;
