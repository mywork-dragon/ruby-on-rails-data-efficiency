import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import { TreeSelect } from 'antd';
import { capitalize } from 'utils/format.utils';

const CategoriesDropdown = ({
  categories,
  filter: {
    value,
  },
  panelKey,
  platform,
  selectedPlatform,
  updateFilter,
}) => {
  const treeData = _.compact(categories.map((x) => {
    if (x.platform === 'android' && x.parent) {
      return null;
    }

    const node = {
      value: x.id.toString(),
      label: x.name.split(' (')[0],
      key: `${x.id}-${x.name}`,
    };

    if (x.subCategories) {
      node.children = x.subCategories.map(y => ({
        value: y.id.toString(),
        label: y.name.split(' (')[0],
        key: `${y.id}-${y.name}`,
      }));
    }

    return node;
  }));

  return (
    <div className="li-select categories">
      <div className="platform-category-label">
        <i className={`fa fa-${platform === 'ios' ? 'apple' : 'android'}`} />
        Categories
      </div>
      <TreeSelect
        disabled={!['all', platform].includes(selectedPlatform)}
        dropdownStyle={{ maxHeight: 200 }}
        getPopupContainer={() => document.getElementById('categories-input')}
        labelInValue
        multiple
        onChange={values => updateFilter(`${platform}Categories`, values, { panelKey })()}
        placeholder={`${capitalize(platform)} Categories`}
        showCheckedStrategy={TreeSelect.SHOW_PARENT}
        style={{ width: '100%' }}
        treeCheckable
        treeData={treeData}
        value={value}
      />
    </div>
  );
};

CategoriesDropdown.propTypes = {
  categories: PropTypes.arrayOf(PropTypes.object).isRequired,
  filter: PropTypes.shape({
    value: PropTypes.array,
  }),
  panelKey: PropTypes.string.isRequired,
  platform: PropTypes.string.isRequired,
  selectedPlatform: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

CategoriesDropdown.defaultProps = {
  filter: {
    value: [],
  },
};

export default CategoriesDropdown;
