import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import Select from 'components/select/CustomSelect.component';
import { capitalize } from 'utils/format.utils';

const CategoriesDropdown = ({
  categories,
  filterCategories,
  platform,
  selectedPlatform,
  onCategoryUpdate,
}) => {
  const options = categories.map(x => ({ value: x.id, label: x.name }));

  return (
    <div className="li-select categories">
      <div className="platform-category-label">
        <i className={`fa fa-${platform === 'ios' ? 'apple' : 'android'}`} />
        Categories
      </div>
      <Select
        closeOnSelect={false}
        disabled={!['all', platform].includes(selectedPlatform)}
        multi
        onChange={onCategoryUpdate}
        options={options}
        placeholder={`${capitalize(platform)} Categories`}
        style={{ marginTop: 5, borderRadius: 0 }}
        value={filterCategories}
      />
    </div>
  );
};

CategoriesDropdown.propTypes = {
  categories: PropTypes.arrayOf(PropTypes.object).isRequired,
  filterCategories: PropTypes.array,
  platform: PropTypes.string.isRequired,
  selectedPlatform: PropTypes.string.isRequired,
  onCategoryUpdate: PropTypes.func.isRequired,
};

CategoriesDropdown.defaultProps = {
  filterCategories: [],
};

export default CategoriesDropdown;
