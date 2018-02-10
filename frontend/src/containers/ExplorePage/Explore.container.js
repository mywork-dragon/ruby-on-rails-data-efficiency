import { connect } from 'react-redux';
import { buildRequest } from 'utils/explore/queryBuilder.utils';

import Explore from './Explore.component';

const mapStateToProps = ({ explorePage: { searchForm, resultsTable: { columns } } }) => {
  buildRequest(searchForm, columns);
  return {
    ...searchForm,
  };
};

const ExploreContainer = connect(
  mapStateToProps,
)(Explore);

export default ExploreContainer;
