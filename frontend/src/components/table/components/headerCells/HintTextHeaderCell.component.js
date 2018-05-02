import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const HintTextHeaderCell = ({
  title,
  hintText,
}) => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      {hintText}
    </Tooltip>
  );

  return (
    <span>
      {title}
      {' '}
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

HintTextHeaderCell.propTypes = {
  title: PropTypes.string.isRequired,
  hintText: PropTypes.string.isRequired,
};

export default HintTextHeaderCell;
