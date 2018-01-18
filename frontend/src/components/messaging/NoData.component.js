import React from 'react';
import PropTypes from 'prop-types';

const NoDataMessage = ({ children }) => (
  <div className="empty-data-ctnr">
    <img src="images/mighty_signal_elephant.png" alt="" />
    {children}
  </div>
);

NoDataMessage.propTypes = {
  children: PropTypes.node.isRequired,
};

export default NoDataMessage;
