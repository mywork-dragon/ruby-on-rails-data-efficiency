import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const RatingsCountHeaderCell = ({ resultType }) => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      {resultType === 'publisher' && <p>Total across all apps</p>}
    </Tooltip>
  );

  return (
    <span>
      Ratings Count
      {' '}
      {resultType === 'publisher' &&
        <OverlayTrigger overlay={helpTooltip} placement="right">
          <span className="fa fa-question-circle" />
        </OverlayTrigger>
      }
    </span>
  );
};

RatingsCountHeaderCell.propTypes = {
  resultType: PropTypes.string,
};

RatingsCountHeaderCell.defaultProps = {
  resultType: 'app',
};

export default RatingsCountHeaderCell;
