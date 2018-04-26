import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';
import { numberShorthand } from 'utils/format.utils';

const options = [0, 1, 2, 3, 4, 5].map(x => ({ value: x, label: `${numberShorthand(x)} network${x === 1 ? '' : 's'}` }));

const operatorOptions = [
  { value: 'more-than', label: 'Greater Than' },
  { value: 'less-than', label: 'Less Than' },
  { value: 'between', label: 'Between' },
];

const NetworkCountFilter = ({
  filter: {
    value: {
      value,
      operator,
    },
  },
  panelKey,
  updateFilter,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Number of Ad Networks:
    </label>
    <div className="input-group ratings-count">
      <Select
        className="small-custom-react-select"
        clearable={false}
        onChange={(val) => {
          const newFilter = {
            operator: val,
          };

          let currentVal = Math.max(...value);
          if (currentVal === -Infinity) currentVal = null;

          switch (val) {
            case 'more-than':
              newFilter.value = [currentVal, null];
              break;
            case 'less-than':
              newFilter.value = [0, currentVal];
              break;
            case 'between':
              newFilter.value = [];
              break;
          }

          updateFilter('adNetworkCount', newFilter, { panelKey })();
        }}
        options={operatorOptions}
        searchable={false}
        simpleValue
        value={operator}
      />
      <div className="between-container">
        {['more-than', 'between'].includes(operator) && (
          <Select
            className="small-custom-react-select"
            clearable
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [val, value[1]],
              };

              if (typeof val !== 'number') newFilter.value = [];

              updateFilter('adNetworkCount', newFilter, { panelKey })();
            }}
            options={options}
            searchable={false}
            simpleValue
            value={value[0]}
          />
        )}
        {operator === 'between' && <span className="and-text">and</span>}
        {['less-than', 'between'].includes(operator) && (
          <Select
            className="small-custom-react-select"
            clearable
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [value[0], val],
              };

              if (typeof val !== 'number') newFilter.value = [];

              updateFilter('adNetworkCount', newFilter, { panelKey })();
            }}
            options={options}
            searchable={false}
            simpleValue
            value={value[1]}
          />
        )}
      </div>
    </div>
  </li>
);

NetworkCountFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.shape({
      value: PropTypes.array,
      operator: PropTypes.string,
    }),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

NetworkCountFilter.defaultProps = {
  filter: {
    value: {
      value: [],
      operator: 'more-than',
    },
  },
};

export default NetworkCountFilter;
