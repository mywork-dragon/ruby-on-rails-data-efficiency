import React from 'react';
import PropTypes from 'prop-types';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = ({
  queryId,
  populateFromQueryId,
  loaded,
  requestAvailableCountries,
}) => {
  if (queryId) {
    populateFromQueryId(queryId);
  }

  if (!loaded) {
    requestAvailableCountries();
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
  loaded: PropTypes.bool.isRequired,
  requestAvailableCountries: PropTypes.func.isRequired,
};

Explore.defaultProps = {
  queryId: '',
};

export default Explore;
