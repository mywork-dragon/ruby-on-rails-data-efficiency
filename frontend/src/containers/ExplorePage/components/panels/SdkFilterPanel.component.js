import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { Button, Radio } from 'antd';
import { panelFilterCount } from 'utils/explore/general.utils';

import FilterCountLabel from '../FilterCountLabel.component';
import SdkFilterGroup from '../SdkFilterGroup.component';

const SdkFilterPanel = ({
  addSdkFilter,
  filters,
  filters: {
    sdks,
  },
  panels,
  panelKey,
  togglePanel,
  updateFilter,
  ...rest
}) => {
  let sdkFilters = [];
  const disableMasterOperator = !sdks || sdks.filters.length <= 1;

  // initialize empty filter if currently no sdk filters
  if (!sdks) {
    addSdkFilter();
  } else {
    sdkFilters = sdks.filters;
  }

  return (
    <Panel expanded={panels[panelKey]}>
      <Panel.Heading onClick={togglePanel(panelKey)}>
        <Panel.Title>
          SDK Data
          <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
          <i className="fa fa-angle-down pull-right" />
        </Panel.Title>
      </Panel.Heading>
      <Panel.Body collapsible>
        <div>
          <Radio.Group
            disabled={disableMasterOperator}
            onChange={e => updateFilter('sdkOperator', e.target.value)()}
            size="small"
            style={{ marginBottom: '10px' }}
            value={sdks.operator}
          >
            <Radio.Button
              value="and"
            >
              AND
            </Radio.Button>
            <Radio.Button
              value="or"
            >
              OR
            </Radio.Button>
          </Radio.Group>
        </div>
        {
          sdkFilters.map((filter, index) => (
            <SdkFilterGroup
              key={`${filter.eventType}${filter.dateRange}${index}`}
              canDelete={sdkFilters.length > 1}
              filter={filter}
              index={index}
              updateFilter={updateFilter}
              {...rest}
            />
          ))
        }
        <Button icon="plus" onClick={() => addSdkFilter()} size="small" type="normal">Add Filter</Button>
      </Panel.Body>
    </Panel>
  );
};

SdkFilterPanel.propTypes = {
  addSdkFilter: PropTypes.func.isRequired,
  filters: PropTypes.shape({
    sdks: PropTypes.object,
  }).isRequired,
  panels: PropTypes.object.isRequired,
  panelKey: PropTypes.string.isRequired,
  togglePanel: PropTypes.func.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default SdkFilterPanel;
