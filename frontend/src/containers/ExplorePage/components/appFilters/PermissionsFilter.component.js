import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';

const PermissionsFilter = ({
  filter,
  appPermissionsOptions,
  updateFilter,
  panelKey,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Permissions:
    </label>
    <div className="input-group">
      <Select
        multi
        onChange={(vals) => {
          updateFilter('appPermissions', vals, { panelKey })();
        }}
        options={appPermissionsOptions.map(x => ({ value: x.key, label: x.display }))}
        searchable={false}
        value={filter.value}
      />
    </div>
  </li>
);

PermissionsFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.array,
  }),
  appPermissionsOptions: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    display: PropTypes.string,
  })).isRequired,
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
};

PermissionsFilter.defaultProps = {
  filter: {
    value: [],
  },
};

export default PermissionsFilter;
