import React from 'react';

import ExploreTableContainer from './containers/ExploreTable.container';
import SearchFormContainer from './containers/SearchForm.container';

const Explore = () => (
  <div className="page">
    <SearchFormContainer />
    <ExploreTableContainer />
  </div>
);

export default Explore;
