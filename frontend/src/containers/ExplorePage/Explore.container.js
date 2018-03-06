import { connect } from 'react-redux';
import { populateFromQueryId, availableCountries } from './redux/Explore.actions';
import Explore from './Explore.component';

const mapDispatchToProps = dispatch => ({
  populateFromQueryId: id => dispatch(populateFromQueryId.request(id)),
  requestAvailableCountries: () => dispatch(availableCountries.request()),
});

const mapStateToProps = ({ explorePage: { explore: { loaded } } }) => ({
  loaded,
});

const ExploreContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(Explore);

export default ExploreContainer;
