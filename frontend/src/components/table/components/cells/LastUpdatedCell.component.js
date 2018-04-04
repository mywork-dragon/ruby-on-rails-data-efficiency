import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { daysAgo, getUpdateDateClass, longDate } from 'utils/format.utils';

const LastUpdatedCell = ({ date }) => {
  if (!date) {
    return (
      <div className="invalid">Not available</div>
    );
  }

  const numDays = daysAgo(date);

  if (Math.sign(numDays) === -1) {
    const tooltip = (
      <Tooltip className="help-tooltip" id="tooltip-right">
        <p>To be updated</p>
      </Tooltip>
    );

    return (
      <span>
        <OverlayTrigger overlay={tooltip} placement="top">
          <span className="tooltip-item">{longDate(date)}</span>
        </OverlayTrigger>
      </span>
    );
  }

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
