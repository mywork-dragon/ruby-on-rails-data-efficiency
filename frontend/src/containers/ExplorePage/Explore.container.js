import { connect } from 'react-redux';
import { populateFromQueryId } from './redux/Explore.actions';
import Explore from './Explore.component';

const mapDispatchToProps = dispatch => ({
  populateFromQueryId: id => dispatch(populateFromQueryId.request(id)),
});

const ExploreContainer = connect(
  null,
  mapDispatchToProps,
)(Explore);

export default ExploreContainer;
