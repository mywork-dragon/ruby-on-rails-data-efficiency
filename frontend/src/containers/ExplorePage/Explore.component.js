import React from 'react';
import PropTypes from 'prop-types';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = ({
  existingId,
  queryId,
  populateFromQueryId,
  shouldFetchCountries,
  requestAvailableCountries,
  shouldFetchCategories,
  requestCategories,
  shouldFetchSdkCategories,
  requestSdkCategories,
}) => {
  if (queryId && !existingId) {
    populateFromQueryId(queryId);
  }

  if (shouldFetchCountries) {
    requestAvailableCountries();
  }

  if (shouldFetchCategories) {
    requestCategories();
  }

  if (shouldFetchSdkCategories) {
    requestSdkCategories();
  }

  return (
    <div className="page explore-page">
      <h4 className="page-title explore-title">
        Explore V2
        {' '}
        <span className="beta-flag">BETA</span>
      </h4>
      <SearchFormContainer />
      <ExploreTableContainer />
    </div>
  );
};

Explore.propTypes = {
  populateFromQueryId: PropTypes.func.isRequired,
  queryId: PropTypes.string,
  existingId: PropTypes.string,
  shouldFetchCountries: PropTypes.bool.isRequired,
  requestAvailableCountries: PropTypes.func.isRequired,
  shouldFetchCategories: PropTypes.bool.isRequired,
  requestCategories: PropTypes.func.isRequired,
  shouldFetchSdkCategories: PropTypes.bool.isRequired,
  requestSdkCategories: PropTypes.func.isRequired,
};

Explore.defaultProps = {
  queryId: '',
  existingId: null,
};

export default Explore;
