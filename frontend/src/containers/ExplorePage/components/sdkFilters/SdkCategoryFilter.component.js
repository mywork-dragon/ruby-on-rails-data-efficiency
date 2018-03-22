import React from 'react';
import PropTypes from 'prop-types';
import { TreeSelect } from 'antd';
import { updateCategorySdks, formatCategorySdksTree, formatCategorySdksValue } from 'utils/explore/general.utils';

const SdkCategoryFilter = ({
  iosSdkCategories,
  androidSdkCategories,
  updateFilter,
  filter,
  index,
}) => {
  const value = formatCategorySdksValue(filter.sdks);

  const treeData = formatCategorySdksTree(iosSdkCategories, androidSdkCategories);

  return (
    <TreeSelect
      dropdownStyle={{ maxHeight: 300 }}
      getPopupContainer={() => document.getElementById(`sdk-filter-${index}`)}
      multiple
      onChange={(values) => {
        const newFilter = {
          ...filter,
          sdks: updateCategorySdks(filter.sdks, values, iosSdkCategories, androidSdkCategories),
        };

        updateFilter('sdks', newFilter, { index })();
      }}
      placeholder="Add SDK Categories"
      showCheckedStrategy={TreeSelect.SHOW_PARENT}
      treeCheckable
      treeData={treeData}
      value={value}
    />
  );
};

SdkCategoryFilter.propTypes = {
  iosSdkCategories: PropTypes.object.isRequired,
  androidSdkCategories: PropTypes.object.isRequired,
  updateFilter: PropTypes.func.isRequired,
  filter: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
};

export default SdkCategoryFilter;
