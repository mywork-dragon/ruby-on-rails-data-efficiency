import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

const AppLogo = ({ app, adIntel, platform }) => {
  const style = {
    width: '30px',
    height: '30px',
  };

  const tooltip = (
    <Tooltip id="tooltip">{app.name}</Tooltip>
  );

  const link = `#/app/${platform}/${app.id}${adIntel ? '/ad-intelligence' : ''}`;

  return (
    <OverlayTrigger overlay={tooltip} placement="top">
      <a href={link} target="_blank">
        <img alt={app.name} src={app.icon} style={style} />
      </a>
    </OverlayTrigger>
  );
};

AppLogo.propTypes = {
  app: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.string,
    favicon: PropTypes.string,
  }).isRequired,
  platform: PropTypes.string.isRequired,
  adIntel: PropTypes.bool,
};

AppLogo.defaultProps = {
  adIntel: false,
};

export default AppLogo;
