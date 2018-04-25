import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import SmallIcon from 'Icons/SmallIcon';

const LocationCell = ({
  locations,
}) => {
  if (!locations || locations.length === 0) {
    return <span className="invalid">No location data</span>;
  } else if (locations.length === 1) {
    const x = locations[0].state || locations[0].city;
    return (
      <span>
        <SmallIcon src={`/lib/images/flags/${locations[0].country_code.toLowerCase()}.png`} />
        <span>{x ? `${x}, ` : ''}{locations[0].country_code}</span>
      </span>
    );
  }

  const popover = (
    <Popover id="popover-trigger-hover-focus">
      <ul className="international-data">
        {locations.map(x => (
          <li key={`location_${x.state}_${x.country_code}`}>
            <SmallIcon src={`/lib/images/flags/${locations[0].country_code.toLowerCase()}.png`} />
            {' '}
            <span>{x.state}, {x.country_code}</span>
          </li>
        ))}
      </ul>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" trigger={['hover', 'focus']}>
        <div>
          <span className="tooltip-item">
            {/* <SmallIcon src={`/lib/images/flags/${locations[0].country_code.toLowerCase()}.png`} /> */}
            <span>{`${locations[0].state}, ${locations[0].country_code}`}</span>
          </span>
        </div>
      </OverlayTrigger>
    </div>
  );
};

LocationCell.propTypes = {
  locations: PropTypes.arrayOf(PropTypes.shape({
    state: PropTypes.string,
    country_code: PropTypes.string,
  })),
};

LocationCell.defaultProps = {
  locations: null,
};

export default LocationCell;
