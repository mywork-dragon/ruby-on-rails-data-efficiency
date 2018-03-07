import React from 'react';
import PropTypes from 'prop-types';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = ({
  queryId,
  populateFromQueryId,
  shouldFetchCountries,
  requestAvailableCountries,
  shouldFetchCategories,
  requestCategories,
}) => {
  if (queryId) {
    populateFromQueryId(queryId);
  }

  if (shouldFetchCountries) {
    requestAvailableCountries();
  }

  if (shouldFetchCategories) {
    requestCategories();
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
  shouldFetchCountries: PropTypes.bool.isRequired,
  requestAvailableCountries: PropTypes.func.isRequired,
  shouldFetchCategories: PropTypes.bool.isRequired,
  requestCategories: PropTypes.func.isRequired,
};

Explore.defaultProps = {
  queryId: '',
};

export default Explore;
