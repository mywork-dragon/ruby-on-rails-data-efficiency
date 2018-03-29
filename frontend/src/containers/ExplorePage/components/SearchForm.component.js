import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { Button } from 'antd';

import AdditionalFilters from './AdditionalFilters.component';
import AdIntelFilterPanel from './adIntelFilters/AdIntelFilterPanel.component';
import AppFilterPanel from './appFilters/AppFilterPanel.component';
import FilterTagsDisplay from './FilterTagsDisplay.component';
import PlatformFilter from './PlatformFilter.component';
import PublisherFilterPanel from './publisherFilters/PublisherFilterPanel.component';
import RankingsFilterPanel from './RankingsFilterPanel.component';
import ResultTypeFilter from './ResultTypeFilter.component';
import SdkFilterPanel from './sdkFilters/SdkFilterPanel.component';

const SearchForm = ({
  canFetch,
  clearFilters,
  expanded,
  includeTakenDown,
  platform,
  resultType,
  requestResults,
  toggleForm,
  loading,
  ...rest
}) => {
  const toggleFormPanel = () => (e) => {
    e.stopPropagation();
    toggleForm();
  };

  return (
    <Panel expanded={expanded} id="search-form-panel" onToggle={toggleFormPanel()}>
      <Panel.Heading onClick={toggleFormPanel()}>
        <Panel.Title>
          Build Your Search
          {
            expanded ? (
              <i className="fa fa-angle-up pull-right" onClick={toggleFormPanel()} />
            ) : (
              <i className="fa fa-angle-down pull-right" />
            )
          }
        </Panel.Title>
      </Panel.Heading>
      <Panel.Collapse>
        <Panel.Body>
          <div className="explore-search-form">
            <div className="basic-filter-group form-group">
              <PlatformFilter platform={platform} {...rest} />
              <AdditionalFilters includeTakenDown={includeTakenDown} {...rest} />
            </div>
            <div className="advanced-filter-group form-group">
              <h4>Add Filters</h4>
              <div className="col-md-6">
                <SdkFilterPanel panelKey="1" platform={platform} {...rest} />
                <AppFilterPanel panelKey="2" platform={platform} {...rest} />
              </div>
              <div className="col-md-6">
                <PublisherFilterPanel panelKey="3" {...rest} />
                <AdIntelFilterPanel panelKey="4" {...rest} />
              </div>
            </div>
            <div className="form-review form-group">
              <h4>Review Filters</h4>
              <FilterTagsDisplay {...rest} />
            </div>
            <div className="search-form-footer form-group">
              <div>
                <Button className="btn btn-primary" onClick={clearFilters()}>Clear Filters</Button>
              </div>
              <div className="search-form-submit">
                {/* <Button className="btn btn-primary" disabled={!canFetch}>Save Search</Button> */}
                <Button
                  className="btn btn-primary"
                  disabled={!canFetch}
                  loading={loading}
                  onClick={requestResults()}
                  style={{ width: 130 }}
                  type="primary"
                >
                  {loading ? 'Loading' : 'Submit Search'}
                </Button>
              </div>
            </div>
          </div>
        </Panel.Body>
      </Panel.Collapse>
    </Panel>
  );
};

SearchForm.propTypes = {
  canFetch: PropTypes.bool,
  clearFilters: PropTypes.func.isRequired,
  expanded: PropTypes.bool,
  includeTakenDown: PropTypes.bool.isRequired,
  platform: PropTypes.string.isRequired,
  requestResults: PropTypes.func.isRequired,
  toggleForm: PropTypes.func.isRequired,
  resultType: PropTypes.string.isRequired,
  loading: PropTypes.bool.isRequired,
};

SearchForm.defaultProps = {
  canFetch: false,
  expanded: true,
};

export default SearchForm;
