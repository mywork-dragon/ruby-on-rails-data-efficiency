import React from 'react';
import PropTypes from 'prop-types';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = ({ queryId, populateFromQueryId }) => {
  if (queryId) {
    populateFromQueryId(queryId);
  }

  return (
    <div className="page">
      <SearchFormContainer />
      <ExploreTableContainer />
    </div>
  );
};

Explore.propTypes = {
  populateFromQueryId: PropTypes.func.isRequired,
  queryId: PropTypes.string,
};

Explore.defaultProps = {
  queryId: '',
};

export default Explore;
