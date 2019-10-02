import React from 'react';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const AdSpendHeaderCell = () => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      <p>Based on Facebook ads seen</p>
    </Tooltip>
  );

  return (
    <span>
      Ad Spend
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

export default AdSpendHeaderCell;
