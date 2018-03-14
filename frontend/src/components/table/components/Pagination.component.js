/* eslint react/forbid-prop-types: 1 */
import React from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';
import { InputNumber, Select } from 'antd';
import ColumnPicker from './ColumnPicker.component';

const Option = Select.Option;

const defaultButton = props => (
  <button type="button" {...props} className="-btn">
    {props.children}
  </button>
);

defaultButton.propTypes = {
  children: PropTypes.element.isRequired,
};

class Pagination extends React.Component {
  constructor (props) {
    super();

    this.getSafePage = this.getSafePage.bind(this);
    this.changePage = this.changePage.bind(this);
    this.applyPage = this.applyPage.bind(this);

    this.state = {
      page: props.page,
    };
  }

  componentWillReceiveProps (nextProps) {
    this.setState({ page: nextProps.page });
  }

  getSafePage (page) {
    if (isNaN(page)) {
      page = this.props.page;
    }
    return Math.min(Math.max(page, 0), this.props.pages - 1);
  }

  changePage (page) {
    page = this.getSafePage(page);
    this.setState({ page });
    if (this.props.page !== page) {
      this.props.onPageChange(page);
    }
  }

  applyPage (e) {
    if (e) { e.preventDefault(); }
    const page = this.state.page;
    this.changePage(page === '' ? this.props.page : page);
  }

  render () {
    const {
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
      PreviousComponent,
      NextComponent,
      updateColumns,
    } = this.props;

    let pagination;

    if (pages === 1) {
      pagination = (
        <span className="-currentPage">
          {page + 1}
        </span>
      );
    } else if (showPageJump && pages > 50) {
      pagination = (
        <div className="-pageJump">
          <InputNumber
            max={pages}
            min={1}
            onBlur={this.applyPage}
            onChange={(val) => {
              const newPage = val - 1;
              if (typeof val !== 'number') {
                return this.setState({ page: val });
              }
              this.setState({ page: this.getSafePage(newPage) });
            }}
            size="small"
            value={this.state.page === '' ? '' : this.state.page + 1}
          />
        </div>
      );
    } else if (showPageJump && pages <= 50) {
      pagination = (
        <div className="-pageJump">
          <Select
            onChange={(val) => {
              const newPage = val - 1;
              onPageChange(newPage);
            }}
            size="small"
            value={page + 1}
          >
            {_.range(1, pages + 1).map((option, i) => (
              // eslint-disable-next-line react/no-array-index-key
              <Option key={i} value={option}>
                {option}
              </Option>
            ))}
          </Select>
        </div>
      );
    }

    return (
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
              <Select
                onChange={val => onPageSizeChange(val)}
                size="small"
                value={pageSize}
              >
                {pageSizeOptions.map((option, i) => (
                    // eslint-disable-next-line react/no-array-index-key
                  <Option key={i} value={option}>
                    {option} {'rows'}
                  </Option>
                  ))}
              </Select>
            </span>}
          <span className="-pageInfo">
            {'Page'}{' '}
            {pagination}
            {' of '}
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
  }
}

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
