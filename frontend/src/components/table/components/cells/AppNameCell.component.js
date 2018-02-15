import React from 'react';
import PropTypes from 'prop-types';

const AppNameCell = ({ app, isAdIntel }) => (
  <div className="resultsTableAppIcon">
    <span>
      <a className="dotted-link" href={`#/app/${app.platform}/${app.id}${isAdIntel ? '/ad-intelligence' : ''}`}>
        <img src={app.icon || app.icon_url} alt={app.name} />
        {app.name}
        {app.price && <i className="fa fa-2 fa-usd" />}
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
  isAdIntel: PropTypes.bool,
};

AppNameCell.defaultProps = {
  isAdIntel: false,
};

export default AppNameCell;
