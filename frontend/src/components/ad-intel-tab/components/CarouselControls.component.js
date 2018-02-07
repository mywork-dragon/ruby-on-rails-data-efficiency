import React from 'react';
import PropTypes from 'prop-types';

import RotateButtonComponent from './RotateButton.component';

const CarouselControlsComponent = ({
  activeIndex,
  format,
  resultsCount,
  updateIndex,
}) => {
  if (resultsCount <= 1 && format !== 'html') {
    return null;
  }

  return (
    <div>
      <div className="carousel-controls">
        { format === 'html' && <RotateButtonComponent /> }
        <div className="control-wrapper">
          <button className="btn btn-bordered-info" onClick={() => updateIndex(activeIndex - 1)}>
            <i className="fa fa-chevron-left" />
          </button>
          <button className="btn btn-bordered-info" onClick={() => updateIndex(activeIndex + 1)}>
            <i className="fa fa-chevron-right" />
          </button>
        </div>
      </div>
    </div>
  );
};

CarouselControlsComponent.propTypes = {
  activeIndex: PropTypes.number.isRequired,
  format: PropTypes.string.isRequired,
  resultsCount: PropTypes.number.isRequired,
  updateIndex: PropTypes.func.isRequired,
};

export default CarouselControlsComponent;
