import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

import AdditionalFilters from './AdditionalFilters.component';
import AdIntelFilterPanel from './panels/AdIntelFilterPanel.component';
import AppFilterPanel from './panels/AppFilterPanel.component';
import ControlledPanelGroup from './panels/ControlledPanelGroup';
import FilterTags from './FilterTags.component';
import PlatformFilter from './PlatformFilter.component';
import PublisherFilterPanel from './panels/PublisherFilterPanel.component';
import RankingsFilterPanel from './panels/RankingsFilterPanel.component';
import ResultTypeFilter from './ResultTypeFilter.component';
import SdkFilterPanel from './panels/SdkFilterPanel.component';

const SearchForm = ({
  activeKey,
  expanded,
  clearFilters,
  includeTakenDown,
  platform,
  resultType,
  requestResults,
  toggleForm,
  updateActivePanel,
  ...rest
}) => {
  const togglePanel = () => (e) => {
    e.stopPropagation();
    toggleForm();
  };

  const handleSelect = () => newKey => () => updateActivePanel(newKey !== activeKey ? newKey : '');

  return (
    <Panel expanded={expanded} id="search-form-panel" onToggle={togglePanel()}>
      <Panel.Heading onClick={togglePanel()}>
        <Panel.Title>
          Build Your Search
          {
            expanded ? (
              <i className="fa fa-times pull-right" onClick={togglePanel()} />
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
              <ResultTypeFilter resultType={resultType} {...rest} />
              <PlatformFilter platform={platform} {...rest} />
              <AdditionalFilters includeTakenDown={includeTakenDown} {...rest} />
            </div>
            <div className="advanced-filter-group form-group">
              <h4>Add Filters</h4>
              <ControlledPanelGroup activeKey={activeKey} handleSelect={handleSelect()} id="panel-group-1">
                <div className="col-md-6">
                  <SdkFilterPanel handleSelect={handleSelect()} />
                  <AppFilterPanel handleSelect={handleSelect()} {...rest} />
                  <PublisherFilterPanel handleSelect={handleSelect()} />
                </div>
                <div className="col-md-6">
                  <AdIntelFilterPanel handleSelect={handleSelect()} />
                  <RankingsFilterPanel handleSelect={handleSelect()} />
                </div>
              </ControlledPanelGroup>
            </div>
            <div className="form-review form-group">
              <h4>Review Filters</h4>
              <FilterTags />
            </div>
            <div className="search-form-footer form-group">
              <div>
                <button className="btn btn-primary" onClick={clearFilters()}>Clear Filters</button>
                <button className="btn btn-primary" onClick={togglePanel()}>Hide Form</button>
              </div>
              <div className="search-form-submit">
                <button className="btn btn-primary">Save Search</button>
                <button className="btn btn-primary" onClick={requestResults()}>Submit Search</button>
              </div>
            </div>
          </div>
        </Panel.Body>
      </Panel.Collapse>
    </Panel>
  );
};

SearchForm.propTypes = {
  activeKey: PropTypes.string,
  clearFilters: PropTypes.func.isRequired,
  expanded: PropTypes.bool,
  includeTakenDown: PropTypes.bool.isRequired,
  platform: PropTypes.string.isRequired,
  requestResults: PropTypes.func.isRequired,
  toggleForm: PropTypes.func.isRequired,
  resultType: PropTypes.string.isRequired,
  updateActivePanel: PropTypes.func.isRequired,
};

SearchForm.defaultProps = {
  activeKey: '',
  expanded: true,
};

export default SearchForm;
