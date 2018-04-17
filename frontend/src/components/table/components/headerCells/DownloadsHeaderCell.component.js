import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const DownloadsHeaderCell = ({ resultType }) => {
  const helpTooltip = (
    <Tooltip className="help-tooltip" id="tooltip-right">
      {resultType === 'publisher' && <p>Total across all apps</p>}
      <p>Only available for Android</p>
    </Tooltip>
  );

  return (
    <span>
      Downloads
      {' '}
      <OverlayTrigger overlay={helpTooltip} placement="right">
        <span className="fa fa-question-circle" />
      </OverlayTrigger>
    </span>
  );
};

DownloadsHeaderCell.propTypes = {
  resultType: PropTypes.string,
};

DownloadsHeaderCell.defaultProps = {
  resultType: 'app',
};

export default DownloadsHeaderCell;
