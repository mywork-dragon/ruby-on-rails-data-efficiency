import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

const Rating = ({
  rating,
  count,
}) => {
  const rounded = Math.round(parseFloat((rating) * 2)) / 2;
  const fullStars = Math.floor(rounded);
  const halfStar = rounded > fullStars;
  const emptyStars = count - fullStars - (halfStar ? 1 : 0);

  const tooltip = <Tooltip id="tooltip-top">{Math.round(parseFloat((rating) * 10)) / 10}</Tooltip>;

  return (
    <OverlayTrigger overlay={tooltip} placement="top">
      <div className="star-rating">
        {_.range(fullStars).map(x => <i key={`star-${x}`} className="fa fa-star" />)}
        {halfStar && <i className="fa fa-star-half-o" />}
        {_.range(emptyStars).map(x => <i key={`empty-star-${x}`} className="fa fa-star-o" />)}
      </div>
    </OverlayTrigger>
  );
};

Rating.propTypes = {
  rating: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  count: PropTypes.number,
};

Rating.defaultProps = {
  count: 5,
  rating: 0,
};

export default Rating;
