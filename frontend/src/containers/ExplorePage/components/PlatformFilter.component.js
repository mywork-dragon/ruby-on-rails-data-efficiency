import React from 'react';
import PropTypes from 'prop-types';

const PlatformFilter = ({
  platform,
  updateFilter,
}) => (
  <div className="basic-filter">
    <h4>
      Platform
    </h4>
    <div className="btn-group">
      {
        ['All', 'iOS', 'Android'].map((text) => {
          const type = text.toLowerCase();
          return (
            <button key={type} className={`btn ${platform === type ? 'btn-primary' : 'btn-default'}`} onClick={updateFilter('platform', type)}>{text}</button>
          );
        })
      }
    </div>
  </div>
);

PlatformFilter.propTypes = {
  platform: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default PlatformFilter;
