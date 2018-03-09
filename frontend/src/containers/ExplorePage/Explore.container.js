import { connect } from 'react-redux';
import { categories, availableCountries } from 'actions/AppStore.actions';
import { populateFromQueryId } from './redux/Explore.actions';
import Explore from './Explore.component';

const mapDispatchToProps = dispatch => ({
  populateFromQueryId: id => dispatch(populateFromQueryId.request(id)),
  requestAvailableCountries: () => dispatch(availableCountries.request()),
  requestCategories: () => dispatch(categories.request()),
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
});

const ExploreContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Explore);

export default ExploreContainer;
