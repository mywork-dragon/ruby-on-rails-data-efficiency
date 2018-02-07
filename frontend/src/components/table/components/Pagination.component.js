/* eslint react/forbid-prop-types: 1 */
import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import _ from 'lodash';

import ColumnPicker from './ColumnPicker.component';

const defaultButton = props => (
  <button type="button" {...props} className="-btn">
    {props.children}
  </button>
);

defaultButton.propTypes = {
  children: PropTypes.element.isRequired,
};

const Pagination = ({
  canNext,
  canPrevious,
  columns,
  onPageChange,
  onPageSizeChange,
  page,
  pages,
  pageSizeOptions,
  pageSize,
  showColumnDropdown,
  showPageSizeOptions,
  showPageJump,
  PreviousComponent = defaultButton,
  NextComponent = defaultButton,
  updateColumns,
}) => (
  <div className="-pagination">
    <div className="-center">
      {showColumnDropdown &&
        <ColumnPicker
          columns={columns}
          onColumnChange={updateColumns}
        />
      }
      {showPageSizeOptions &&
        <span className="select-wrap -pageSizeOptions">
          <select
            onChange={e => onPageSizeChange(Number(e.target.value))}
            value={pageSize}
          >
            {pageSizeOptions.map((option, i) => (
              // eslint-disable-next-line react/no-array-index-key
              <option key={i} value={option}>
                {option} {'rows'}
              </option>
            ))}
          </select>
        </span>}
      <span className="-pageInfo">
        {'Page'}{' '}
        {showPageJump
          ?
            <div className="-pageJump">
              <select
                onChange={(e) => {
                  const page = Number(e.target.value) - 1;
                  onPageChange(page);
                }}
                value={page + 1}
              >
                {_.range(1, pages + 1).map((option, i) => (
                  // eslint-disable-next-line react/no-array-index-key
                  <option key={i} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            </div> :
            <span className="-currentPage">
              {page + 1}
            </span>}{' '}
        {'of'}{' '}
        <span className="-totalPages">{pages || 1}</span>
      </span>
    </div>
    <div className="-previous">
      <PreviousComponent
        disabled={!canPrevious}
        onClick={() => {
          if (!canPrevious) return;
          onPageChange(page - 1);
        }}
      >
        <i className="fa fa-angle-left" />
      </PreviousComponent>
    </div>
    <div className="-next">
      <NextComponent
        disabled={!canNext}
        onClick={() => {
          if (!canNext) return;
          onPageChange(page + 1);
        }}
      >
        <i className="fa fa-angle-right" />
      </NextComponent>
    </div>
  </div>
);

Pagination.propTypes = {
  canPrevious: PropTypes.bool.isRequired,
  canNext: PropTypes.bool.isRequired,
  columns: PropTypes.shape({
    App: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
    Publisher: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  }),
  NextComponent: PropTypes.func,
  onPageChange: PropTypes.func.isRequired,
  onPageSizeChange: PropTypes.func.isRequired,
  page: PropTypes.number.isRequired,
  pages: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  pageSizeOptions: PropTypes.arrayOf(PropTypes.number).isRequired,
  PreviousComponent: PropTypes.func,
  showColumnDropdown: PropTypes.bool,
  showPageSizeOptions: PropTypes.bool,
  showPageJump: PropTypes.bool,
  updateColumns: PropTypes.func,
};

Pagination.defaultProps = {
  columns: {},
  showColumnDropdown: false,
  showPageSizeOptions: false,
  showPageJump: false,
  PreviousComponent: defaultButton,
  NextComponent: defaultButton,
  paginationStyle: {},
  updateColumns: null,
};

export default Pagination;
