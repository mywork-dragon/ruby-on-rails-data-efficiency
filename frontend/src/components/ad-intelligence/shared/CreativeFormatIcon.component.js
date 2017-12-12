import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

const CreativeFormatIcon = ({ format }) => {
  const formatMap = {
    html: { icon: 'html5', label: 'HTML' },
    image: { icon: 'picture-o', label: 'Image' },
    video: { icon: 'film', label: 'Video' },
  };

  const icon = formatMap[format].icon;
  const label = formatMap[format].label;
  const className = `format-icon fa fa-fw fa-${icon}`;

  const tooltip = (
    <Tooltip id="tooltip">{label}</Tooltip>
  );

  return (
    <OverlayTrigger placement="top" overlay={tooltip}>
      <i className={className} />
    </OverlayTrigger>
  );
};

CreativeFormatIcon.propTypes = {
  format: PropTypes.string.isRequired,
};

export default CreativeFormatIcon;
