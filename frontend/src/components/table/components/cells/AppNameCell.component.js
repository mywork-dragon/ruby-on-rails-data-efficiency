import React from 'react';
import PropTypes from 'prop-types';

const AppNameCell = ({ app, platform, isAdIntel }) => (
  <div className="resultsTableAppIcon">
    <span>
      <a className="dotted-link" href={`#/app/${platform || app.platform}/${app.id}${isAdIntel ? '/ad-intelligence' : ''}`}>
        <img src={app.icon} alt={app.name} />
        {app.name}
        {app.price ? <i className="fa fa-2 fa-usd" /> : null}
      </a>
    </span>
  </div>
);

AppNameCell.propTypes = {
  app: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
    icon: PropTypes.string,
  }).isRequired,
  platform: PropTypes.string,
  isAdIntel: PropTypes.bool,
};

AppNameCell.defaultProps = {
  isAdIntel: false,
  platform: 'ios',
};

export default AppNameCell;
