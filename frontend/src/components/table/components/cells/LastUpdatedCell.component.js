import React from 'react';
import PropTypes from 'prop-types';

import { daysAgo, getUpdateDateClass } from 'utils/format.utils';

const LastUpdatedCell = ({ date }) => {
  if (!date) {
    return (
      <div>Not available</div>
    );
  }

  return (
    <div>
      <span className={getUpdateDateClass(date)}>
        <strong>{daysAgo(date)}</strong>
      </span>
      {' '}
      days ago
    </div>
  );
};

LastUpdatedCell.propTypes = {
  date: PropTypes.string,
};

LastUpdatedCell.defaultProps = {
  date: null,
};

export default LastUpdatedCell;
