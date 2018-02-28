import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { Button, Radio } from 'antd';
import { panelFilterCount } from 'utils/explore/general.utils';

import FilterCountLabel from '../FilterCountLabel.component';
import SdkFilterGroup from '../SdkFilterGroup.component';

const SdkFilterPanel = ({
  addSdkFilter,
  filters: {
    sdks,
  },
  handleSelect,
  panelKey,
  updateFilter,
  ...rest
}) => {
  let filters = [];
  const disableMasterOperator = !sdks || sdks.filters.length <= 1;

  // initialize empty filter if currently no sdk filters
  if (!sdks) {
    addSdkFilter();
  } else {
    filters = sdks.filters;
  }

  return (
    <Panel eventKey={panelKey}>
      <Panel.Heading onClick={handleSelect(panelKey)}>
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
          filters.map((filter, index) => (
            <SdkFilterGroup
              key={`${filter.eventType}${filter.dateRange}${index}`}
              canDelete={filters.length > 1}
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
  handleSelect: PropTypes.func,
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

SdkFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default SdkFilterPanel;
