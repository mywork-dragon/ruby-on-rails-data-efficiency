import { connect } from 'react-redux';

import Explore from './Explore.component';

const mapStateToProps = (store) => {
  const explore = store.explore;

  return {
    apps: explore.apps,
    tableOptions: explore.tableOptions,
  };
};

const ExploreContainer = connect(
  mapStateToProps,
)(Explore);

export default ExploreContainer;
