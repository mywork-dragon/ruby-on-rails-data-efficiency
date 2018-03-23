import React from 'react';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const RatingHeaderCell = () => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      <p>Based on all versions</p>
    </Tooltip>
  );

  return (
    <span>
      Rating
      {' '}
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

export default RatingHeaderCell;

