import React from 'react';
import PropTypes from 'prop-types';
import ReactTable, { ReactTableDefaults } from 'react-table';
import classnames from 'classnames';
import { numberWithCommas, capitalize } from 'utils/format.utils';
import { generateColumns, totalNumPages } from 'utils/table.utils';
import { headerNames } from './redux/column.models';
import ListDropdownContainer from './containers/ListDropdown.container';
import Pagination from './components/Pagination.component';
import LoadingSpinner from './components/Spinner.component';
import CustomHeaderCell from './components/headerCells/CustomHeaderCell.component';

Object.assign(ReactTableDefaults, {
  className: '-striped',
  pageSizeOptions: [20, 50, 75, 100],
  resizable: false,
});

const Table = ({
  canFetch,
  columns,
  error,
  csvLink,
  isManual,
  loading,
  message,
  onCsvExport,
  onPageChange,
  onPageSizeChange,
  onSortedChange,
  pageNum,
  pageSize,
  results,
  resultsCount,
  resultType,
  selectedItems,
  showColumnDropdown,
  showControls,
  showHeader,
  sort,
  title,
  toggleAll,
  toggleItem,
  updateColumns,
  updateDefaultPageSize,
  ...rest
}) => {
  const allSelected = selectedItems.length === results.length;
  const columnHeaders = generateColumns(columns, selectedItems, allSelected, toggleItem, toggleAll);
  const pages = totalNumPages(resultsCount, pageSize);
  const minRows = loading ? 10 : 0;

  const handlePageSizeChange = (newSize) => {
    updateDefaultPageSize(newSize);
    onPageSizeChange(newSize);
  };

  const getTheadThProps = ({ sorted }, rowInfo, column) => ({
    column,
    sorted: sorted.find(col => col.id === column.id),
    sortable: column.sortable,
    resultType,
  });

  const getTdProps = () => rest;

  return (
    <section className="panel panel-default table-dynamic">
      {
        showHeader && (
          <div className="panel-heading" id="dashboardResultsTableHeading">
            <strong><i className="fa fa-list panel-icon" />{title}</strong>
            {' '}
            <span id="dashboardResultsTableHeadingNumDisplayed">
              | {`${numberWithCommas(resultsCount)} ${capitalize(resultType)}${resultsCount > 1 ? 's' : ''}`}
            </span>
            {canFetch && csvLink && resultsCount ? (
              <a href={csvLink}>
                <button
                  className="btn btn-primary pull-right"
                  onClick={() => onCsvExport()}
                >
                  Export to CSV
                </button>
              </a>
            ) : (
              <button
                className="btn btn-primary pull-right"
                disabled
              >
                Export to CSV
              </button>
            )}
            {toggleAll && toggleItem && resultType === 'app' && (
              <ListDropdownContainer
                selectedItems={selectedItems}
              />
            )}
          </div>
        )
      }
      {
        isManual ? (
          <ReactTable
            columns={columnHeaders}
            data={results}
            getPaginationProps={() => ({
              columns,
              showColumnDropdown,
              updateColumns,
            })}
            getTdProps={getTdProps}
            getTheadThProps={getTheadThProps}
            getTrProps={(state, rowInfo) => ({
              className: rowInfo && !rowInfo.original.appAvailable && rowInfo.original.taken_down && 'faded',
            })}
            loading={loading}
            LoadingComponent={LoadingSpinner}
            manual={isManual}
            minRows={minRows}
            noDataText={message}
            onPageChange={onPageChange}
            onPageSizeChange={handlePageSizeChange}
            onSortedChange={onSortedChange}
            page={pageNum}
            pages={pages}
            pageSize={pageSize}
            PaginationComponent={Pagination}
            showPaginationBottom={showControls && !error}
            showPaginationTop={showControls && !error}
            sorted={sort}
            style={{
              minHeight: results.length ? '0px' : '500px',
            }}
            TdComponent={({
              className, children, style,
            }) => (
              <div className={classnames('rt-td', className)} role="gridcell" style={style}>
                {children}
              </div>
            )}
            ThComponent={CustomHeaderCell}
          />
        ) : (
          <ReactTable
            columns={columnHeaders}
            data={results}
            defaultSorted={sort}
            getTdProps={getTdProps}
            getTheadThProps={getTheadThProps}
            loading={loading}
            minRows={0}
            onSortedChange={onSortedChange}
            pageSize={results.length}
            showPaginationBottom={false}
            showPaginationTop={false}
            TdComponent={({
              className, children, style,
            }) => (
              <div className={classnames('rt-td', className)} role="gridcell" style={style}>
                {children}
              </div>
            )}
            ThComponent={CustomHeaderCell}
          />
        )
      }
    </section>
  );
};

Table.propTypes = {
  canFetch: PropTypes.bool,
  columns: PropTypes.shape({
    App: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
    Publisher: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  }).isRequired,
  error: PropTypes.bool,
  csvLink: PropTypes.string,
  isManual: PropTypes.bool,
  loading: PropTypes.bool,
  message: PropTypes.string,
  onCsvExport: PropTypes.func,
  onPageChange: PropTypes.func,
  onPageSizeChange: PropTypes.func,
  onSortedChange: PropTypes.func,
  pageNum: PropTypes.number,
  pageSize: PropTypes.number,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  resultType: PropTypes.string,
  selectedItems: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    type: PropTypes.string,
  })),
  showColumnDropdown: PropTypes.bool,
  showControls: PropTypes.bool,
  showHeader: PropTypes.bool,
  sort: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    desc: PropTypes.bool,
  })),
  title: PropTypes.string,
  toggleAll: PropTypes.func,
  toggleItem: PropTypes.func,
  resultsCount: PropTypes.number.isRequired,
  updateColumns: PropTypes.func,
  updateDefaultPageSize: PropTypes.func.isRequired,
};

Table.defaultProps = {
  canFetch: false,
  csvLink: null,
  error: false,
  isManual: false,
  loading: false,
  message: 'No results',
  onCsvExport: () => {},
  onPageChange: null,
  onPageSizeChange: null,
  onSortedChange: null,
  pageNum: 0,
  pageSize: 20,
  resultType: 'app',
  sort: [
    {
      id: headerNames.LAST_UPDATED,
      desc: true,
    },
  ],
  selectedItems: [],
  showColumnDropdown: false,
  showControls: false,
  showHeader: true,
  title: '',
  toggleAll: null,
  toggleItem: null,
  updateColumns: null,
};

export default Table;
