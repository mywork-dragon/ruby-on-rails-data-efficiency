import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { daysAgo, getUpdateDateClass, longDate } from 'utils/format.utils';

const DateCell = ({ updateDate, releaseDate, type }) => {
  const date = updateDate || releaseDate;

  if (!date) {
    return (
      <div className="invalid">Not available</div>
    );
  }

  const numDays = daysAgo(date);

  if (Math.sign(numDays) === -1) {
    let text = 'update';
    if (type === 'publisher') {
      text = 'update or release';
    } else if (releaseDate) {
      text = 'release';
    }
    const tooltip = (
      <Tooltip className="help-tooltip" id="tooltip-right">
        <p>Upcoming {text}</p>
      </Tooltip>
    );

    return (
      <span>
        <OverlayTrigger overlay={tooltip} placement="top">
          <span className="tooltip-item">{longDate(date)}</span>
        </OverlayTrigger>
      </span>
    );
  } else if (releaseDate) {
    return <span>{longDate(date)}</span>;
  }

  return (
    <div>
      <span className={getUpdateDateClass(updateDate)}>
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

DateCell.propTypes = {
  updateDate: PropTypes.string,
  releaseDate: PropTypes.string,
  type: PropTypes.string,
};

DateCell.defaultProps = {
  updateDate: null,
  releaseDate: null,
  type: 'app',
};

export default DateCell;
