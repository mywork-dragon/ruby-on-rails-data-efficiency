import React from 'react';
import PropTypes from 'prop-types';

const AdSpendCell = ({ adSpend }) => (
  <div>
    <span>
      <i className={`fa fa-circle status-${adSpend}`} />
      {adSpend ? ' Yes' : ' No'}
    </span>
  </div>
);

AdSpendCell.propTypes = {
  adSpend: PropTypes.bool.isRequired,
};

export default AdSpendCell;
