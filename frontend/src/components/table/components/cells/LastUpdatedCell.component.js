import React from 'react';
import PropTypes from 'prop-types';

import { getUpdateDateClass } from 'utils/format.utils';

const LastUpdatedCell = ({ numDays }) => (
  <div>
    <span className={getUpdateDateClass(numDays)}>
      <strong>{numDays}</strong>
    </span>
    {' '}
    days ago
  </div>
);

LastUpdatedCell.propTypes = {
  numDays: PropTypes.number.isRequired,
};

export default LastUpdatedCell;
