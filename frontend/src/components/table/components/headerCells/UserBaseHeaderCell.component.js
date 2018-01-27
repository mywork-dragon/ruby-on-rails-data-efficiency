import React from 'react';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const UserBaseHeaderCell = () => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      <p>An estimate of how many active users an app has, based on ratings for the current release.</p>
      <p>Elite: 50,000 total ratings or average of 7 ratings per day.</p>
      <p>Strong: 10,000 total ratings or average of 1 rating per day.</p>
      <p>Moderate: 100 total ratings or average of 0.1 rating per day.</p>
      <p>Weak: Anything less.</p>
    </Tooltip>
  );

  return (
    <span>
      User Base
      {' '}
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

export default UserBaseHeaderCell;
