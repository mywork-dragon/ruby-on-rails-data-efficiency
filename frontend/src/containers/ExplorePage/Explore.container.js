import { connect } from 'react-redux';
import { needAppCategories, needAvailableCountries, needSdkCategories } from 'selectors/appStore.selectors';
import { needPermissions } from 'selectors/account.selectors';
import { loadPermissions } from 'actions/Account.actions';
import * as appStore from 'actions/AppStore.actions';
import { populateFromQueryId } from './redux/Explore.actions';
import Explore from './Explore.component';


const mapDispatchToProps = dispatch => ({
  populateFromQueryId: id => dispatch(populateFromQueryId.request(id)),
  requestAvailableCountries: () => dispatch(appStore.availableCountries.request()),
  requestCategories: () => dispatch(appStore.categories.request()),
  requestSdkCategories: () => dispatch(appStore.sdkCategories.request()),
  requestPermissions: () => dispatch(loadPermissions.request()),
});

const mapStateToProps = (state) => {
  const {
    explorePage: {
      explore: {
        loaded,
        queryId,
      },
    },
  } = state;

  return {
    loaded,
    existingId: queryId,
    shouldFetchCategories: needAppCategories(state),
    shouldFetchCountries: needAvailableCountries(state),
    shouldFetchSdkCategories: needSdkCategories(state),
    shouldFetchPermissions: needPermissions(state),
  };
};

const ExploreContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Explore);

export default ExploreContainer;
