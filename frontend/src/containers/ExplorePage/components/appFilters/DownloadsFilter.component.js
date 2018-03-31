import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';
import { numberShorthand } from 'utils/format.utils';

const options = [
  0,
  50000,
  500000,
  10000000,
  100000000,
  1000000000,
  5000000000,
].map(x => ({ value: x, label: numberShorthand(x) }));

const operatorOptions = [
  { value: 'more-than', label: 'Greater Than' },
  { value: 'less-than', label: 'Less Than' },
  { value: 'between', label: 'Between' },
];

const DownloadsFilter = ({
  filter: {
    value: {
      value,
      operator,
    },
  },
  panelKey,
  updateFilter,
  platform,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Downloads (Android only):
    </label>
    <div className="input-group ratings-count">
      <Select
        clearable={false}
        disabled={platform === 'ios'}
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

          updateFilter('downloads', newFilter, { panelKey })();
        }}
        options={operatorOptions}
        searchable={false}
        simpleValue
        value={operator}
      />
      <div className="between-container">
        {['more-than', 'between'].includes(operator) && (
          <Select
            clearable
            disabled={platform === 'ios'}
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [val, value[1]],
              };

              if (!val) newFilter.value = [];

              updateFilter('downloads', newFilter, { panelKey })();
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
            clearable
            disabled={platform === 'ios'}
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [value[0], val],
              };

              if (!val) newFilter.value = [];

              updateFilter('downloads', newFilter, { panelKey })();
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

DownloadsFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.shape({
      value: PropTypes.array,
      operator: PropTypes.string,
    }),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
  platform: PropTypes.string.isRequired,
};

DownloadsFilter.defaultProps = {
  filter: {
    value: {
      value: [],
      operator: 'more-than',
    },
  },
};

export default DownloadsFilter;
