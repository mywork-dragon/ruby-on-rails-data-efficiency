import React from 'react';
import PropTypes from 'prop-types';
import ReactTable, { ReactTableDefaults } from 'react-table';
import { generateColumns, totalNumPages } from 'utils/table.utils';
import { headerNames } from './redux/column.models';
import ListDropdownContainer from './containers/ListDropdown.container';
import Pagination from './components/Pagination.component';
import LoadingSpinner from './components/Spinner.component';

Object.assign(ReactTableDefaults, {
  className: '-striped',
  pageSizeOptions: [20, 50, 75, 100],
  resizable: false,
});

const Table = ({
  canFetch,
  columns,
  error,
  isAdIntel,
  isManual,
  loading,
  message,
  pageNum,
  pageSize,
  requestResults,
  results,
  resultsCount,
  selectedItems,
  showColumnDropdown,
  showControls,
  sort,
  title,
  toggleAll,
  toggleItem,
  updateColumns,
  updateDefaultPageSize,
  updatePageSize,
}) => {
  const allSelected = selectedItems.length === results.length;
  const columnHeaders = generateColumns(columns, selectedItems, allSelected, toggleItem, toggleAll, isAdIntel);
  const pages = totalNumPages(resultsCount, pageSize)
  const minRows = loading ? 10 : 0;

  const onPageChange = (pageIndex) => {
    if (canFetch) {
      requestResults({
        pageNum: pageIndex,
        pageSize,
        sort,
      });
    }
  };

  const onPageSizeChange = (newSize) => {
    updatePageSize(newSize);
    updateDefaultPageSize(newSize);
    if (canFetch) {
      requestResults({
        pageNum: 0,
        pageSize: newSize,
        sort,
      });
    }
  };

  const onSortedChange = (newSort) => {
    if (canFetch) {
      requestResults({
        pageNum: 0,
        pageSize,
        sort: newSort,
      });
    }
  };

  return (
    <section className="panel panel-default table-dynamic">
      <div className="panel-heading" id="dashboardResultsTableHeading">
        <strong><i className="fa fa-list panel-icon" />{title}</strong>
        {' '}
        <span id="dashboardResultsTableHeadingNumDisplayed">
          | {resultsCount} Apps
        </span>
        <ListDropdownContainer
          selectedItems={selectedItems}
        />
      </div>
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
            getTrProps={(state, rowInfo) => ({
              className: rowInfo && !rowInfo.original.appAvailable && rowInfo.original.taken_down && 'faded',
            })}
            loading={loading}
            LoadingComponent={LoadingSpinner}
            manual={isManual}
            minRows={minRows}
            noDataText={message}
            onPageChange={onPageChange}
            onPageSizeChange={onPageSizeChange}
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
          />
        ) : (
          <ReactTable
            columns={columnHeaders}
            data={results}
            defaultSorted={sort}
            loading={loading}
            minRows={0}
            showPaginationBottom={false}
            showPaginationTop={false}
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
  error: PropTypes.bool.isRequired,
  isAdIntel: PropTypes.bool,
  isManual: PropTypes.bool,
  loading: PropTypes.bool,
  message: PropTypes.string,
  requestResults: PropTypes.func,
  pageNum: PropTypes.number,
  pageSize: PropTypes.number,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  selectedItems: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    type: PropTypes.string,
  })),
  showColumnDropdown: PropTypes.bool,
  showControls: PropTypes.bool,
  sort: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    desc: PropTypes.bool,
  })),
  title: PropTypes.string.isRequired,
  toggleAll: PropTypes.func.isRequired,
  toggleItem: PropTypes.func.isRequired,
  resultsCount: PropTypes.number.isRequired,
  updateColumns: PropTypes.func,
  updateDefaultPageSize: PropTypes.func.isRequired,
  updatePageSize: PropTypes.func,
};

Table.defaultProps = {
  canFetch: false,
  isAdIntel: false,
  isManual: false,
  loading: false,
  message: 'No results',
  pageNum: 0,
  pageSize: 20,
  requestResults: null,
  sort: [
    {
      id: headerNames.LAST_UPDATED,
      desc: true,
    },
  ],
  selectedItems: [],
  showColumnDropdown: false,
  showControls: false,
  updateColumns: null,
  updatePageSize: () => {},
};

export default Table;
