import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { Icon } from 'antd';

const ColumnHeader = ({
  toggleSort,
  className,
  children,
  sorted,
  sortable,
  column,
}) => (
  <div className={classNames('rt-th', className)}>
    {children}
    {sortable && (
      <div className="pull-right table-sort">
        <Icon
          className={classNames('sort-arrow', { active: sorted && !sorted.desc })}
          onClick={() => {
            if (!sorted || sorted.desc) {
              column.defaultSortDesc = false;
              toggleSort(column);
            }
          }}
          type="up"
        />
        <Icon
          className={classNames('sort-arrow', { active: sorted && sorted.desc })}
          onClick={() => {
            if (!sorted || !sorted.desc) {
              column.defaultSortDesc = true;
              toggleSort(column);
            }
          }}
          type="down"
        />
      </div>
    )}
  </div>
);

ColumnHeader.propTypes = {
  column: PropTypes.shape({
    sortable: PropTypes.bool,
  }).isRequired,
  className: PropTypes.string.isRequired,
  sorted: PropTypes.shape({
    desc: PropTypes.bool,
    id: PropTypes.string,
  }),
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  toggleSort: PropTypes.func.isRequired,
  sortable: PropTypes.bool,
};

ColumnHeader.defaultProps = {
  sorted: null,
  sortable: true,
};

export default ColumnHeader;
