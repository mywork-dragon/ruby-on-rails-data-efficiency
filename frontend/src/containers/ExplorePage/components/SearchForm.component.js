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

class SearchForm extends Component {
  constructor () {
    super();

    this.togglePanel = this.togglePanel.bind(this);
    this.handleSelect = this.handleSelect.bind(this);

    this.state = {
      expanded: true,
      activeKey: '',
    };
  }

  togglePanel () {
    return () => this.setState({ expanded: !this.state.expanded, activeKey: '' });
  }

  handleSelect(activeKey) {
    if (activeKey !== this.state.activeKey) {
      this.setState({ activeKey });
    } else {
      this.setState({ activeKey: '' });
    }
  }

  render () {
    const {
      clearFilters,
      filters,
      includeTakenDown,
      platform,
      resultType,
      requestResults,
      updateFilter,
    } = this.props;

    const { expanded, activeKey } = this.state;

    return (
      <Panel expanded={expanded} id="search-form-panel" onToggle={this.togglePanel()}>
        <Panel.Heading onClick={this.togglePanel()}>
          <Panel.Title>
            Build Your Search
            {
              expanded ? (
                <i className="fa fa-times pull-right" onClick={this.togglePanel()} />
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
                <ResultTypeFilter resultType={resultType} updateFilter={updateFilter} />
                <PlatformFilter platform={platform} updateFilter={updateFilter} />
                <AdditionalFilters includeTakenDown={includeTakenDown} updateFilter={updateFilter} />
              </div>
              <div className="advanced-filter-group form-group">
                <h4>Add Filters</h4>
                <ControlledPanelGroup activeKey={activeKey} handleSelect={key => () => this.handleSelect(key)} id="panel-group-1">
                  <div className="col-md-6">
                    <SdkFilterPanel handleSelect={key => () => this.handleSelect(key)} />
                    <AppFilterPanel filters={filters} handleSelect={key => () => this.handleSelect(key)} updateFilter={updateFilter} />
                    <PublisherFilterPanel handleSelect={key => () => this.handleSelect(key)} />
                  </div>
                  <div className="col-md-6">
                    <AdIntelFilterPanel handleSelect={key => () => this.handleSelect(key)} />
                    <RankingsFilterPanel handleSelect={key => () => this.handleSelect(key)} />
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
                  <button className="btn btn-primary" onClick={this.togglePanel()}>Hide Form</button>
                </div>
                <div className="search-form-submit">
                  <button className="btn btn-primary">Save Search</button>
                  <button className="btn btn-primary" onClick={() => requestResults()}>Submit Search</button>
                </div>
              </div>
            </div>
          </Panel.Body>
        </Panel.Collapse>
      </Panel>
    );
  }
}

SearchForm.propTypes = {
  clearFilters: PropTypes.func.isRequired,
  filters: PropTypes.object.isRequired,
  includeTakenDown: PropTypes.bool.isRequired,
  platform: PropTypes.string.isRequired,
  requestResults: PropTypes.func.isRequired,
  resultType: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default SearchForm;
