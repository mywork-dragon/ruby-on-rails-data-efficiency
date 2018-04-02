import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';

const options = [
  { value: 0, label: '0 stars' },
  { value: 0.5, label: '0.5 star' },
  { value: 1.0, label: '1.0 star' },
  { value: 1.5, label: '1.5 stars' },
  { value: 2.0, label: '2.0 stars' },
  { value: 2.5, label: '2.5 stars' },
  { value: 3.0, label: '3.0 stars' },
  { value: 3.5, label: '3.5 stars' },
  { value: 4.0, label: '4.0 stars' },
  { value: 4.5, label: '4.5 stars' },
  { value: 5.0, label: '5.0 stars' },
];

const operatorOptions = [
  { value: 'more-than', label: 'Greater Than' },
  { value: 'less-than', label: 'Less Than' },
  { value: 'between', label: 'Between' },
];

const RatingFilter = ({
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
      All Version Rating:
    </label>
    <div className="input-group ratings-count">
      <Select
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

          updateFilter('rating', newFilter, { panelKey })();
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
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [val, value[1]],
              };

              if (typeof val !== 'number') newFilter.value = [];

              updateFilter('rating', newFilter, { panelKey })();
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
            onChange={(val) => {
              const newFilter = {
                operator,
                value: [value[0], val],
              };

              if (typeof val !== 'number') newFilter.value = [];

              updateFilter('rating', newFilter, { panelKey })();
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

RatingFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.shape({
      value: PropTypes.array,
      operator: PropTypes.string,
    }),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

RatingFilter.defaultProps = {
  filter: {
    value: {
      value: [],
      operator: 'more-than',
    },
  },
};

export default RatingFilter;

