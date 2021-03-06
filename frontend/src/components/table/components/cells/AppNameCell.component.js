import React from 'react';
import PropTypes from 'prop-types';

const AppNameCell = ({
  app: {
    icon,
    icon_url,
    platform,
    id,
    name,
    price,
    price_category,
  },
  isAdIntel,
}) => (
  <div className="resultsTableAppIcon">
    <span>
      <a className="dotted-link" href={`#/app/${platform}/${id}${isAdIntel ? '/ad-intelligence' : ''}`} target="_blank">
        {(icon || icon_url) && <img src={icon || icon_url} />}
        {name ? name.replace(/\u00AD/g, '') : 'No name'}
        {' '}
        {(price || price_category === 'paid') && <i className="fa fa-2 fa-usd" />}
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
