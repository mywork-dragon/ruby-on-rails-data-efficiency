import React from 'react';
import PropTypes from 'prop-types';

import { capitalize } from 'utils/format.utils';

import { ButtonDropdown } from 'simple-react-bootstrap';

const CreativeFilterDropdown = ({
  activeFilters,
  filters,
  label,
  toggleFilter,
  type,
}) => (
  <span className="ui-select">
    <div className="btn-group">
      <div className="categories-dropdown">
        <div className="multiselect-parent btn-group dropdown-multiselect">
          <div id="creative-filter-dropdown">
            <ButtonDropdown ignoreContentClick>
              <button>{label}</button>
              <ul className="dropdown-menu-form">
                {
                  filters.map((filter) => {
                    const val = filter.id ? filter.id : filter;
                    const isActive = activeFilters.includes(val);
                    return (
                      <li key={val}>
                        <div className="option">
                          <div className="checkbox">
                            <label>
                              <input checked={isActive} className="checkboxInput" onChange={() => toggleFilter(val, type)} type="checkbox" />
                              <span>{filter.id ? filter.name : capitalize(filter)}</span>
                            </label>
                          </div>
                        </div>
                      </li>
                    );
                  })
                }
              </ul>
            </ButtonDropdown>
          </div>
        </div>
      </div>
    </div>
  </span>
);

CreativeFilterDropdown.propTypes = {
  activeFilters: PropTypes.arrayOf(PropTypes.string).isRequired,
  filters: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.string, PropTypes.object])).isRequired,
  label: PropTypes.string.isRequired,
  toggleFilter: PropTypes.func.isRequired,
  type: PropTypes.string.isRequired,
};

export default CreativeFilterDropdown;
