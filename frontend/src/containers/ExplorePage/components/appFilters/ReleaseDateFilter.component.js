import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';
import { DatePicker } from 'antd';

const { RangePicker } = DatePicker;

const options = [
  { value: 'week', label: 'Last Week' },
  { value: 'month', label: 'Last Month' },
  { value: 'three-months', label: 'Last 3 Months' },
  { value: 'six-months', label: 'Last 6 Months' },
  { value: 'year', label: 'Last Year' },
  { value: 'custom', label: 'Custom Date Range' },
];

const ReleaseDateFilter = ({
  filter,
  filter: {
    value: {
      dateRange,
      dates,
    },
  },
  panelKey,
  updateFilter,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Release Date:
    </label>
    <div className="input-group release-date" id="release-date-filter">
      <Select
        className="small-custom-react-select"
        clearable
        onChange={(val) => {
          if (!val) {
            updateFilter('releaseDate', null, { panelKey })();
          } else {
            const newFilter = {
              ...filter.value,
              dateRange: val,
            };

            updateFilter('releaseDate', newFilter, { panelKey })();
          }
        }}
        options={options}
        searchable={false}
        simpleValue
        value={dateRange}
      />
      {dateRange === 'custom' && (
        <RangePicker
          getCalendarContainer={() => document.getElementById(('release-date-filter'))}
          onChange={(value) => {
            const newFilter = {
              ...filter.value,
              dates: value,
            };
            updateFilter('releaseDate', newFilter, { panelKey })();
          }}
          size="small"
          style={{ width: '225px' }}
          value={dates}
        />
      )}
    </div>
  </li>
);

ReleaseDateFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.shape({
      dateRange: PropTypes.string,
      dates: PropTypes.array,
    }),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

ReleaseDateFilter.defaultProps = {
  filter: {
    value: {
      dateRange: null,
      dates: [],
    },
  },
};

export default ReleaseDateFilter;
