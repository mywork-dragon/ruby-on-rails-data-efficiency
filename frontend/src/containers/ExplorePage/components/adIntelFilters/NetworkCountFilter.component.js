import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import { Select } from 'antd';

const Option = Select.Option;

const NetworkCountFilter = ({
  filter,
  filter: {
    value,
    value: {
      start,
      end,
    },
  },
  panelKey,
  updateFilter,
  networkStore: {
    adNetworks,
  },
}) => {
  const startRange = _.range(1, Object.values(adNetworks).filter(x => x.can_access).length + 1);
  if (end === 0 || end > startRange[startRange.length - 1]) {
    end = startRange[startRange.length - 1];
  }

  const endRange = _.range(start, startRange[startRange.length - 1] + 1);

  return (
    <li>
      <label className="filter-label">
        Number of Networks Advertised On:
      </label>
      <div className="input-group network-count">
        Between
        <Select
          onChange={(val) => {
            const newFilter = {
              ...value,
              start: val,
              end,
            };

            updateFilter('adNetworkCount', newFilter, { panelKey })();
          }}
          size="small"
          value={start}
        >
          {
            startRange.map(x => (
              <Option value={x}>{x}</Option>
            ))
          }
        </Select>
        and
        <Select
          onChange={(val) => {
            const newFilter = {
              ...value,
              end: val,
            };

            updateFilter('adNetworkCount', newFilter, { panelKey })();
          }}
          size="small"
          value={end}
        >
          {
            endRange.map(x => (
              <Option value={x}>{x}</Option>
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
  networkStore: PropTypes.shape({
    adNetworks: PropTypes.object,
  }).isRequired,
};

NetworkCountFilter.defaultProps = {
  filter: {
    value: {
      start: 1,
      end: 0,
    },
  },
};

export default NetworkCountFilter;
