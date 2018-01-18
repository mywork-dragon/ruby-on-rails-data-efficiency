import React from 'react';
import PropTypes from 'prop-types';

import CreativeFormatList from 'components/ad-intel-tab/components/CreativeFormatList.component';

const CreativeFormatCell = ({ formats }) => (
  <td>
    <CreativeFormatList formats={formats} />
  </td>
);

CreativeFormatCell.propTypes = {
  formats: PropTypes.arrayOf(PropTypes.string),
};

CreativeFormatCell.defaultProps = {
  formats: [],
};

export default CreativeFormatCell;
