import React from 'react';
import PropTypes from 'prop-types';

const LastUpdatedHeaderCell = ({ resultType }) => (
  <span>
    {resultType === 'publisher' && 'Last Update/Release'}
    {resultType === 'app' && 'Last Updated'}
  </span>
);

LastUpdatedHeaderCell.propTypes = {
  resultType: PropTypes.string,
};

LastUpdatedHeaderCell.defaultProps = {
  resultType: 'app',
};

export default LastUpdatedHeaderCell;
