import React from 'react';
import PropTypes from 'prop-types';
import { Select } from 'antd';

const Option = Select.Option;

const AvailableCountriesFilter = ({
  availableCountries,
  filter: {
    value,
    value: {
      countries,
      operator,
      condition,
    },
  },
  panelKey,
  updateFilter,
}) => {
  const allowMultiple = condition && condition !== 'only-available-in';

  const updateCondition = (val) => {
    const newFilter = { ...value };
    newFilter.condition = val;
    updateFilter('availableCountries', newFilter, { panelKey })();
  };

  const updateOperator = (val) => {
    const newFilter = { ...value };
    newFilter.operator = val;
    updateFilter('availableCountries', newFilter, { panelKey })();
  };

  const updateCountries = (val) => {
    const newFilter = { ...value };
    if (!allowMultiple) {
      val = [val];
    }
    newFilter.countries = val;
    updateFilter('availableCountries', newFilter, { panelKey })();
  };

  return (
    <li className="li-filter">
      <label className="filter-label">
        Available Countries:
      </label>
      <div className="input-group available-countries" id="available-countries-filter">
        <div className="options-group">
          <Select
            getPopupContainer={() => document.getElementById(('available-countries-filter'))}
            onChange={updateCondition}
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
                getPopupContainer={() => document.getElementById(('available-countries-filter'))}
                onChange={updateOperator}
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
        <div className="li-select">
          <Select
            allowClear={allowMultiple}
            filterOption={false}
            getPopupContainer={() => document.getElementById(('available-countries-filter'))}
            labelInValue
            mode={allowMultiple ? 'multiple' : ''}
            onChange={updateCountries}
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
};

AvailableCountriesFilter.propTypes = {
  availableCountries: PropTypes.arrayOf(PropTypes.object).isRequired,
  filter: PropTypes.shape({
    value: PropTypes.shape({
      countries: PropTypes.array,
      operator: PropTypes.string,
    }),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

AvailableCountriesFilter.defaultProps = {
  filter: {
    value: {
      countries: [],
      operator: 'any',
      condition: 'only-available-in',
    },
  },
};

export default AvailableCountriesFilter;
