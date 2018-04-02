import { connect } from 'react-redux';
import { getSavedSearches, loadSavedSearch, deleteSavedSearch } from 'actions/Account.actions';
import { needSavedSearches, getSearches } from 'selectors/account.selectors';
import { updateSavedSearchPage, toggleForm } from 'containers/ExplorePage/redux/Explore.actions';

import SavedSearchComponent from '../components/savedSearch/SavedSearch.component';

const mapDispatchToProps = dispatch => ({
  requestSavedSearches: () => dispatch(getSavedSearches.request()),
  loadSavedSearch: (id, queryId) => dispatch(loadSavedSearch.request(id, queryId)),
  deleteSavedSearch: id => dispatch(deleteSavedSearch.request(id)),
  toggleForm: type => dispatch(toggleForm(type)),
  changePage: page => () => dispatch(updateSavedSearchPage(page)),
});

const mapStateToProps = (state) => {
  const { account: { savedSearches: { fetching } }, explorePage: { explore: { savedSearchExpanded, searchPage } } } = state;
  const searches = getSearches(state);

  return {
    searches,
    fetching,
    shouldFetchSearches: needSavedSearches(state),
    savedSearchExpanded,
    searchPage,
    totalPages: Math.ceil(searches.length / 5),
  };
};

const SavedSearchContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(SavedSearchComponent);

export default SavedSearchContainer;
