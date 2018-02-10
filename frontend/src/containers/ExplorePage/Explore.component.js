import React from 'react';
import PropTypes from 'prop-types';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = ({
  apps,
  tableOptions,
}) => (
  <div className="page">
    <SearchFormContainer />
    <ExploreTableContainer />
  </div>
);

Explore.propTypes = {
  apps: PropTypes.arrayOf(PropTypes.object),
  tableOptions: PropTypes.shape({
    pageSize: PropTypes.number,
    pageNum: PropTypes.number,
  }),
};

Explore.defaultProps = {
  apps: [],
  tableOptions: {
    pageSize: 20,
    pageNum: 1,
  },
};

export default Explore;
