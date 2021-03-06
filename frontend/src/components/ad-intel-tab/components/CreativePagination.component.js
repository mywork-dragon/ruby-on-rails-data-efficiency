import React from 'react';
import PropTypes from 'prop-types';
import UltimatePagination from 'Table/components/OldPagination.component';

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
        <UltimatePagination
          currentPage={pageNum}
          hidePreviousAndNextPageLinks
          onChange={requestCreatives}
          totalPages={totalPages}
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
