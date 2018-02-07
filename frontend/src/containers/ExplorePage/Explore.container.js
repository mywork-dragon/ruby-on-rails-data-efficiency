import { connect } from 'react-redux';

import Explore from './Explore.component';

const mapStateToProps = ({ explorePage }) => ({
  apps: explorePage.apps,
  tableOptions: explorePage.tableOptions,
});

const ExploreContainer = connect(
  mapStateToProps,
)(Explore);

export default ExploreContainer;
