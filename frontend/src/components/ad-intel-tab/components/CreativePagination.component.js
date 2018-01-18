import React from 'react';
import PropTypes from 'prop-types';

import { Pagination } from 'react-bootstrap';

const PaginationComponent = ({
  requestCreatives,
  pageNum,
  pageSize,
  resultsCount,
}) => {
  const totalPages = Math.ceil(resultsCount / pageSize);

  return (
    <div className="row">
      <div className="col-md-12 text-right pagination-container">
        <Pagination
          activePage={pageNum}
          boundaryLinks={resultsCount > 50}
          bsSize="small"
          buttonComponentClass="span"
          items={totalPages}
          maxButtons={5}
          onSelect={requestCreatives}
        />
      </div>
    </div>
  );
};

PaginationComponent.propTypes = {
  requestCreatives: PropTypes.func.isRequired,
  pageNum: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  resultsCount: PropTypes.number.isRequired,
};

export default PaginationComponent;
