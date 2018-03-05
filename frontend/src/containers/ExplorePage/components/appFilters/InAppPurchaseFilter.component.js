import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Checkbox } from 'antd';

const InAppPurchaseFilter = () => (
  <li>
    <label className="filter-label">
      In-App Purchases:
    </label>
    {
      ['yes', 'no'].map(option => (
        <Checkbox>
          {capitalize(option)}
        </Checkbox>
      ))
    }
  </li>
);

export default InAppPurchaseFilter;
