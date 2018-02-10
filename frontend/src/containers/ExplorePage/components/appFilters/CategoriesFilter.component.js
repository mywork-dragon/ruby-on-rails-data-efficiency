import React from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import { ButtonDropdown } from 'simple-react-bootstrap';

const CategoriesFilter = ({ filter: { value }, updateFilter }) => (
  <li>
    <label className="filter-label">
      Categories:
    </label>
    <span className="ui-select">
      <div className="multiselect-parent btn-group dropdown-multiselect">
        <div>
          <ButtonDropdown ignoreContentClick>
            <button>Multiselect!</button>
            <ul className="dropdown-menu-form">
              {
                ['Games', 'Productivity', 'Food & Drink'].map(filter => (
                  <li key={filter}>
                    <div className="option">
                      <div className="checkbox">
                        <label>
                          <input
                            checked={value.includes(filter)}
                            className="checkboxInput"
                            onChange={updateFilter('app_category', filter)}
                            type="checkbox"
                          />
                          <span>{filter}</span>
                        </label>
                      </div>
                    </div>
                  </li>
                ))
              }
            </ul>
          </ButtonDropdown>
        </div>
      </div>
    </span>
  </li>
);

CategoriesFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.array,
    displayText: PropTypes.string,
  }),
  updateFilter: PropTypes.func.isRequired,
};

CategoriesFilter.defaultProps = {
  filter: {
    value: [],
    displayText: '',
  },
};

export default CategoriesFilter;
