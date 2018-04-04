import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { daysAgo, longDate } from 'utils/format.utils';

const ReleaseDateCell = ({ date }) => {
  if (!date) {
    return (
      <div className="invalid">Not available</div>
    );
  }

  const numDays = daysAgo(date);

  if (Math.sign(numDays) === -1) {
    const tooltip = (
      <Tooltip className="help-tooltip" id="tooltip-right">
        <p>To be released</p>
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
    <span>{longDate(date)}</span>
  );
};

ReleaseDateCell.propTypes = {
  date: PropTypes.string,
};

ReleaseDateCell.defaultProps = {
  date: null,
};

export default ReleaseDateCell;
