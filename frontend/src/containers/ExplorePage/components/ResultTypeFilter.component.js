import React from 'react';
import PropTypes from 'prop-types';

const ResultTypeFilter = ({
  resultType,
  updateFilter,
}) => (
  <div className="basic-filter">
    <h4>
      Type of Result
    </h4>
    <div className="btn-group">
      {
        ['App', 'Publisher'].map((text) => {
          const type = text.toLowerCase();
          return (
            <button key={type} className={`btn ${resultType === type ? 'btn-primary' : 'btn-default'}`} onClick={updateFilter('resultType', type)}>{text}</button>
          );
        })
      }
    </div>
  </div>
);

ResultTypeFilter.propTypes = {
  resultType: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default ResultTypeFilter;
