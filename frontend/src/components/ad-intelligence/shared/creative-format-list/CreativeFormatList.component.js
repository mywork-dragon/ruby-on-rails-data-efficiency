import React from 'react';
import PropTypes from 'prop-types';

import CreativeFormatIcon from '../CreativeFormatIcon.component';

const CreativeFormatList = ({ formats }) => {
  const divStyle = {
    display: 'inline-block',
  };

  return (
    <div style={divStyle}>
      {formats.length ? formats.map(format =>
        (
          <span key={format}>
            <CreativeFormatIcon format={format} />
          </span>
        )) : <span>None</span>}
    </div>
  );
};

CreativeFormatList.propTypes = {
  formats: PropTypes.arrayOf(PropTypes.string),
};

CreativeFormatList.defaultProps = {
  formats: [],
};

export default CreativeFormatList;
