import React from 'react';
import PropTypes from 'prop-types';

const InAppPurchaseFilter = () => (
  <li>
    <label className="filter-label">
      In-App Purchases:
    </label>
    <label className="explore-checkbox">
      <input type="checkbox" />
      <span>Yes</span>
    </label>
  </li>
);

export default InAppPurchaseFilter;
