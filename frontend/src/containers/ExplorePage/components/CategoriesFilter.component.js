import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';
import PlatformOption from 'components/select/platformOption.component';
import PlatformValue from 'components/select/platformValue.component';

const CategoriesFilter = ({
  title,
  options,
  value,
  placeholder,
  onCategoryUpdate,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      {title}
    </label>
    <div className="input-group">
      <Select
        allowSelectAll
        closeOnSelect={false}
        multi
        onChange={onCategoryUpdate}
        optionComponent={PlatformOption}
        options={options}
        placeholder={placeholder}
        value={value}
        valueComponent={PlatformValue}
      />
    </div>
  </li>
);

CategoriesFilter.propTypes = {
  title: PropTypes.string,
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  value: PropTypes.arrayOf(PropTypes.object),
  placeholder: PropTypes.string,
  onCategoryUpdate: PropTypes.func.isRequired,
};

CategoriesFilter.defaultProps = {
  title: 'Categories:',
  placeholder: 'Select...',
  value: [],
};

export default CategoriesFilter;
