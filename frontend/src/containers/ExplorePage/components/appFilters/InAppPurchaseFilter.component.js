import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Radio } from 'antd';

const InAppPurchaseFilter = ({
  filter: {
    value,
  },
  panelKey,
  updateFilter,
}) => (
  <li>
    <label className="filter-label">
      In-App Purchases:
    </label>
    {
      ['yes', 'no'].map(option => (
        <Radio
          key={option}
          checked={value === option}
          onClick={updateFilter('inAppPurchases', option, { panelKey })}
          type="radio"
          value={option}
        >
          {capitalize(option)}
        </Radio>
      ))
    }
  </li>
);

InAppPurchaseFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.string,
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

InAppPurchaseFilter.defaultProps = {
  filter: {
    value: '',
  },
};


export default InAppPurchaseFilter;
