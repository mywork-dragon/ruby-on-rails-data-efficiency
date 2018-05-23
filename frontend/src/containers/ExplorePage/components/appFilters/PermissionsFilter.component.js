import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import Select from 'components/select/CustomSelect.component';
import PlatformOption from 'components/select/platformOption.component';

const PermissionsFilter = ({
  filter,
  appPermissionsOptions,
  updateFilter,
  panelKey,
  platform,
}) => {
  const options = _.sortBy(appPermissionsOptions
    .filter(x => platform === 'all' || x.platforms.includes(platform))
    .map(x => ({
      value: x.key,
      label: x.display,
      ios: x.platforms.includes('ios'),
      android: x.platforms.includes('android'),
    })), x => x.label);

  return (
    <li className="li-filter">
      <label className="filter-label">
        Permissions:
      </label>
      <div className="input-group">
        <Select
          closeOnSelect={false}
          multi
          onSelectResetsInput={false}
          onChange={(vals) => {
            updateFilter('appPermissions', vals, { panelKey })();
          }}
          optionComponent={PlatformOption}
          options={options}
          value={filter.value}
        />
      </div>
    </li>
  );
};

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
  platform: PropTypes.string.isRequired,
};

PermissionsFilter.defaultProps = {
  filter: {
    value: [],
  },
};

export default PermissionsFilter;
