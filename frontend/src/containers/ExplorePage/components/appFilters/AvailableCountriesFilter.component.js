import React from 'react';
import PropTypes from 'prop-types';
import { Select } from 'antd';

const Option = Select.Option;

const AvailableCountriesFilter = ({
  availableCountries,
  filter: {
    value: {
      countries,
      operator,
      condition,
    },
  },
  updateFilter,
}) => {
  const allowMultiple = condition && condition !== 'only-available-in';

  return (
    <li>
      <label className="filter-label">
        Available Countries:
      </label>
      <div className="input-group available-countries">
        <div className="options-group">
          <Select
            onChange={val => updateFilter('availableCountries', val, { field: 'condition' })()}
            size="small"
            style={{
              width: '150px',
            }}
            value={condition || 'only-available-in'}
          >
            <Option value="only-available-in">Only Available in</Option>
            <Option value="available-in">Available in</Option>
            <Option value="not-available-in">Not Available in</Option>
          </Select>
          {
            allowMultiple &&
              <Select
                onChange={val => updateFilter('availableCountries', val, { field: 'operator' })()}
                size="small"
                value={operator || 'any'}
              >
                <Option value="any">Any</Option>
                <Option value="all">All</Option>
              </Select>
          }
        </div>
        {
          allowMultiple &&
          <div className="following">
            of the following
          </div>
        }
        <div className="countries-select">
          <Select
            allowClear={allowMultiple}
            filterOption={false}
            labelInValue
            mode={allowMultiple ? 'multiple' : ''}
            onChange={(values) => {
              if (!allowMultiple) {
                values = [values];
              }

              updateFilter('availableCountries', values, { field: 'countries' })();
            }}
            placeholder={`Select Countr${allowMultiple ? 'ies' : 'y'}`}
            value={countries}
          >
            {availableCountries.map(x => (
              <Option key={`${x.name}${x.id}`} value={`${x.id}`}>
                {x.name}
              </Option>
            ))}
          </Select>
        </div>
      </div>
    </li>
  );
}

AvailableCountriesFilter.propTypes = {
  availableCountries: PropTypes.arrayOf(PropTypes.object).isRequired,
  filter: PropTypes.shape({
    value: PropTypes.shape({
      countries: PropTypes.array,
      operator: PropTypes.string,
    }),
  }),
  updateFilter: PropTypes.func.isRequired,
};

AvailableCountriesFilter.defaultProps = {
  filter: {
    value: {
      countries: [],
      operator: 'any',
    },
  },
};

export default AvailableCountriesFilter;
