import React from 'react';
import PropTypes from 'prop-types';

const AppNameCell = ({ app, platform, isAdIntel }) => (
  <td className="resultsTableAppIcon">
    <span>
      <a href={`#/app/${platform || app.platform}/${app.id}${isAdIntel ? '/ad-intelligence' : ''}`}>
        <img src={app.icon} alt={app.name} />
        {app.name}
      </a>
    </span>
  </td>
);

AppNameCell.propTypes = {
  app: PropTypes.shape({
    id: PropTypes.string,
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
