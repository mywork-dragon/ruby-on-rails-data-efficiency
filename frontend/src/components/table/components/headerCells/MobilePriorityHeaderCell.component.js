import React from 'react';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const MobilePriorityHeaderCell = () => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      <p>How actively the app is being developed, based on how recently the app has been updated.</p>
      <p>High: Updated within the past 2 months.</p>
      <p>Medium: 2-4 months.</p>
      <p>Low: More than 4 months ago.</p>
    </Tooltip>
  );

  return (
    <span>
      Mobile Priority
      {' '}
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

export default MobilePriorityHeaderCell;
