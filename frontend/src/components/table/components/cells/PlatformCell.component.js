import React from 'react';
import PropTypes from 'prop-types';

const PlatformCell = ({ platform }) => (
  <div>
    <i className={`fa fa-2 fa-${platform === 'ios' ? 'apple' : 'android'}`} />
  </div>
);

PlatformCell.propTypes = {
  platform: PropTypes.string.isRequired,
};

export default PlatformCell;
