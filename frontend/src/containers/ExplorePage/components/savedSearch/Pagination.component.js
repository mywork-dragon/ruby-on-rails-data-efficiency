import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'antd';

const Pagination = ({ searchPage, changePage, totalPages }) => {
  const canPrev = searchPage !== 0;
  const canNext = searchPage !== totalPages - 1 && totalPages > 1;

  return (
    <div className="pull-right saved-search-pagination">
      {canPrev && <Button icon="left" onClick={changePage(searchPage - 1)} />}
      {canNext && <Button icon="right" onClick={changePage(searchPage + 1)} />}
    </div>
  );
};

Pagination.propTypes = {
  searchPage: PropTypes.number.isRequired,
  changePage: PropTypes.func.isRequired,
  totalPages: PropTypes.number.isRequired,
};

export default Pagination;
