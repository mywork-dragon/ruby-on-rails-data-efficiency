import { connect } from 'react-redux';
import { getSavedSearches, loadSavedSearch, deleteSavedSearch } from 'actions/Account.actions';
import { needSavedSearches, getSearches } from 'selectors/account.selectors';
import { toggleForm } from 'containers/ExplorePage/redux/Explore.actions';

import SavedSearchComponent from '../components/savedSearch/SavedSearch.component';

const mapDispatchToProps = dispatch => ({
  requestSavedSearches: () => dispatch(getSavedSearches.request()),
  loadSavedSearch: (id, queryId) => dispatch(loadSavedSearch.request(id, queryId)),
  deleteSavedSearch: id => dispatch(deleteSavedSearch.request(id)),
  toggleForm: type => dispatch(toggleForm(type)),
});

const mapStateToProps = (state) => {
  const { account: { savedSearches: { fetching } }, explorePage: { explore: { savedSearchExpanded } } } = state;

  return {
    searches: getSearches(state),
    fetching,
    shouldFetchSearches: needSavedSearches(state),
    savedSearchExpanded,
  };
};

const SavedSearchContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(SavedSearchComponent);

export default SavedSearchContainer;
