import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

import LoadingSpinner from 'components/table/components/Spinner.component';
import Pagination from './Pagination.component';
import SavedSearchTableRow from './SavedSearchTableRow.component';

const SavedSearchComponent = ({
  fetching,
  searches,
  shouldFetchSearches,
  requestSavedSearches,
  savedSearchExpanded,
  searchPage,
  toggleForm,
  ...rest
}) => {
  if (shouldFetchSearches) {
    requestSavedSearches();
  }

  let content;

  if (searches.length) {
    const start = searchPage * 5;
    const end = start + 5;
    const pageSearches = searches.slice(start, end);

    content = (
      <div>
        <table className="table table-hover">
          <thead>
            <tr>
              {/* <th>ID</th> */}
              <th className="search-name">Name</th>
              <th>Filters</th>
              <th>Created At</th>
              <th style={{ textAlign: 'center' }}>Delete</th>
            </tr>
          </thead>
          <tbody>
            {pageSearches.map(search => <SavedSearchTableRow key={`search-${search.id}`} search={search} {...rest} />)}
          </tbody>
        </table>
        <Pagination searchPage={searchPage} {...rest} />
      </div>
    );
  } else {
    content = (
      <div className="no-searches">
        No searches - Create a search below
      </div>
    );
  }

  const toggleFormPanel = () => (e) => {
    e.stopPropagation();
    toggleForm('savedSearch');
  };

  return (
    <Panel expanded={savedSearchExpanded} id="saved-search-panel" onToggle={toggleFormPanel()}>
      <Panel.Heading onClick={toggleFormPanel()}>
        <Panel.Title>
          Saved Searches
          {savedSearchExpanded ? (
            <i className="fa fa-angle-up pull-right" onClick={toggleFormPanel()} />
            ) : (<i className="fa fa-angle-down pull-right" />)
          }
        </Panel.Title>
      </Panel.Heading>
      <Panel.Collapse>
        <Panel.Body>
          <div className="saved-search-panel-body">
            {fetching ? (
              <div className="spinner-container">
                <LoadingSpinner loading />
              </div>
            ) : content}
          </div>
        </Panel.Body>
      </Panel.Collapse>
    </Panel>
  );
};

SavedSearchComponent.propTypes = {
  fetching: PropTypes.bool.isRequired,
  searches: PropTypes.arrayOf(PropTypes.object).isRequired,
  shouldFetchSearches: PropTypes.bool.isRequired,
  requestSavedSearches: PropTypes.func.isRequired,
  savedSearchExpanded: PropTypes.bool.isRequired,
  toggleForm: PropTypes.func.isRequired,
  searchPage: PropTypes.number.isRequired,
};

export default SavedSearchComponent;
