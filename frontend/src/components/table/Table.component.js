import React from 'react';
import PropTypes from 'prop-types';
import ReactTable from 'react-table';
import { generateColumns } from 'utils/table.utils';
import ListDropdownContainer from 'Table/containers/ListDropdown.container';

const Table = ({
  defaultSort,
  headers,
  loadMockData,
  results,
  selectedItems,
  showControls,
  title,
  toggleAll,
  toggleItem,
  totalCount,
}) => {
  if (results.length === 0 && loadMockData) {
    loadMockData();
  }

  const allSelected = selectedItems.length === results.length;
  const columns = generateColumns(headers, selectedItems, allSelected, toggleItem, toggleAll);

  return (
    <section className="panel panel-default table-dynamic">
      <div className="panel-heading" id="dashboardResultsTableHeading">
        <strong><i className="fa fa-list panel-icon" />{title}</strong>
        {' '}
        <span id="dashboardResultsTableHeadingNumDisplayed">
          | {totalCount} Apps
        </span>
        <ListDropdownContainer
          selectedItems={selectedItems}
        />
      </div>
      <ReactTable
        className="-striped"
        columns={columns}
        data={results}
        defaultSorted={[defaultSort]}
        minRows={0}
        resizable={false}
        showPaginationBottom={false}
        showPaginationTop={showControls}
      />
    </section>
  );
};

Table.propTypes = {
  defaultSort: PropTypes.shape({
    id: PropTypes.string,
    desc: PropTypes.bool,
  }),
  headers: PropTypes.arrayOf(PropTypes.string).isRequired,
  loadMockData: PropTypes.func,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  selectedItems: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    type: PropTypes.string,
  })),
  showControls: PropTypes.bool,
  title: PropTypes.string.isRequired,
  toggleAll: PropTypes.func.isRequired,
  toggleItem: PropTypes.func.isRequired,
  totalCount: PropTypes.number.isRequired,
};

Table.defaultProps = {
  defaultSort: null,
  loadMockData: null,
  selectedItems: [],
  showControls: false,
};

export default Table;
