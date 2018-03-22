import { connect } from 'react-redux';
import * as appStore from 'actions/AppStore.actions';
import { populateFromQueryId } from './redux/Explore.actions';
import Explore from './Explore.component';

const mapDispatchToProps = dispatch => ({
  populateFromQueryId: id => dispatch(populateFromQueryId.request(id)),
  requestAvailableCountries: () => dispatch(appStore.availableCountries.request()),
  requestCategories: () => dispatch(appStore.categories.request()),
  requestSdkCategories: () => dispatch(appStore.sdkCategories.request()),
});

const mapStateToProps = ({
  explorePage: {
    explore: {
      loaded,
      queryId,
    },
  },
  appStoreInfo: {
    categories: {
      loaded: categoriesLoaded,
      fetching: categoriesFetching,
    },
    sdkCategories: {
      loaded: sdkCategoriesLoaded,
      fetching: sdkCategoriesFetching,
    },
    availableCountries: {
      loaded: countriesLoaded,
      fetching: countriesFetching,
    },
  },
}) => ({
  loaded,
  existingId: queryId,
  shouldFetchCategories: !categoriesLoaded && !categoriesFetching,
  shouldFetchCountries: !countriesLoaded && !countriesFetching,
  shouldFetchSdkCategories: !sdkCategoriesLoaded && !sdkCategoriesFetching,
});

const ExploreContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Explore);

export default ExploreContainer;
