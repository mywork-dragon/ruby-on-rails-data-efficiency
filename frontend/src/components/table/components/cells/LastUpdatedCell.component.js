import React from 'react';
import PropTypes from 'prop-types';

import { daysAgo, getUpdateDateClass } from 'utils/format.utils';

const LastUpdatedCell = ({ date }) => {
  if (!date) {
    return (
      <div className="invalid">Not available</div>
    );
  }

  const numDays = daysAgo(date);

  return (
    <div>
      <span className={getUpdateDateClass(date)}>
        <strong>{numDays === 0 ? 'Today' : numDays}</strong>
      </span>
      {
        numDays > 0 && (
          <span>
            {' '}
            day{numDays > 1 ? 's' : ''} ago
          </span>
        )
      }
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
