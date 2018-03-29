import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import { Select } from 'antd';

const Option = Select.Option;

const NetworkCountFilter = ({
  filter: {
    value,
    value: {
      start,
      end,
    },
  },
  panelKey,
  updateFilter,
  adNetworks,
}) => {
  const startRange = _.range(1, adNetworks.length + 1);
  if (end === 0 || end > startRange[startRange.length - 1]) {
    end = startRange[startRange.length - 1];
  }

  const endStart = start === 'x' ? 1 : start;

  const endRange = _.range(endStart, startRange[startRange.length - 1] + 1);

  return (
    <li className="li-filter">
      <label className="filter-label">
        Number of Networks Advertised On:
      </label>
      <div className="input-group network-count">
        Between
        <Select
          defaultValue="x"
          onChange={(val) => {
            let newFilter = {
              ...value,
              start: val,
            };

            if (newFilter.end === 'x') {
              newFilter.end = endRange[endRange.length - 1];
            }

            if (val === 'x') {
              newFilter = null;
            }

            updateFilter('adNetworkCount', newFilter, { panelKey })();
          }}
          size="small"
          value={start}
        >
          <Option value="x">X</Option>
          {
            startRange.map(x => (
              <Option key={x}>{x}</Option>
            ))
          }
        </Select>
        and
        <Select
          defaultValue="x"
          onChange={(val) => {
            let newFilter = {
              ...value,
              end: val,
            };

            if (newFilter.start === 'x') {
              newFilter.start = 1;
            }

            if (val === 'x') {
              newFilter = null;
            }

            updateFilter('adNetworkCount', newFilter, { panelKey })();
          }}
          size="small"
          value={end}
        >
          <Option value="x">X</Option>
          {
            endRange.map(x => (
              <Option key={x}>{x}</Option>
            ))
          }
        </Select>
        networks
      </div>
    </li>
  );
};

NetworkCountFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.object,
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
  adNetworks: PropTypes.arrayOf(PropTypes.object),
};

NetworkCountFilter.defaultProps = {
  adNetworks: [],
  filter: {
    value: {
      start: 'x',
      end: 'x',
    },
  },
};

export default NetworkCountFilter;
