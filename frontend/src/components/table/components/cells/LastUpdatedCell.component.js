import React from 'react';
import PropTypes from 'prop-types';

import { daysAgo, getUpdateDateClass } from 'utils/format.utils';

const LastUpdatedCell = ({ date }) => (
  <div>
    <span className={getUpdateDateClass(date)}>
      <strong>{daysAgo(date)}</strong>
    </span>
    {' '}
    days ago
  </div>
);

LastUpdatedCell.propTypes = {
  date: PropTypes.string.isRequired,
};

export default LastUpdatedCell;
