import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const RatingHeaderCell = ({ resultType }) => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      {resultType === 'publisher' && <p>Average across all apps</p>}
      {resultType === 'app' && <p>Based on all versions</p>}
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

RatingHeaderCell.propTypes = {
  resultType: PropTypes.string,
};

RatingHeaderCell.defaultProps = {
  resultType: 'app',
};

export default RatingHeaderCell;
