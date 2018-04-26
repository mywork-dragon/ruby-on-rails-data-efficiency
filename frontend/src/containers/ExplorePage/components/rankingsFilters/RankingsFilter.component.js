import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';

const RankingsFilter = ({
  filter: {
    value,
    value: {
      eventType,
      operator,
      values,
      trendOperator,
      dateRange,
    },
  },
  updateFilter,
  panelKey,
}) => {
  const eventTypeOptions = [
    { value: 'rank', label: 'are ranked' },
    { value: 'trend', label: 'have moved' },
    { value: 'newcomer', label: 'have first appeared on a chart' },
  ];

  const operatorOptions = [
    { value: 'more-than', label: 'Greater Than' },
    { value: 'less-than', label: 'Less Than' },
    { value: 'between', label: 'Between' },
  ];

  const trendOptions = [
    { value: 'up', label: 'Up' },
    { value: 'down', label: 'Down' },
  ];

  const options = [10, 50, 100, 200, 300, 500, 1000].map(x => ({ value: x, label: x }));

  const rangeOperator = (
    <Select
      className="small-custom-react-select"
      clearable={false}
      onChange={(val) => {
        const newFilter = {
          ...value,
          operator: val,
        };

        let currentVal = Math.max(...values);
        if (currentVal === -Infinity) currentVal = null;

        switch (val) {
          case 'more-than':
            newFilter.values = [currentVal, null];
            break;
          case 'less-than':
            newFilter.values = [0, currentVal];
            break;
          case 'between':
            newFilter.values = [];
            break;
        }

        updateFilter('rankings', newFilter, { panelKey })();
      }}
      options={operatorOptions}
      searchable={false}
      simpleValue
      value={operator}
    />
  );

  const numberRange = (
    <div className="between-container">
      {['more-than', 'between'].includes(operator) && (
        <Select
          className="small-custom-react-select"
          clearable
          onChange={(val) => {
            const newFilter = {
              ...value,
              values: [val, values[1]],
            };

            if (typeof val !== 'number') newFilter.values = [];

            updateFilter('rankings', newFilter, { panelKey })();
          }}
          options={options}
          searchable={false}
          simpleValue
          value={values[0]}
        />
      )}
      {operator === 'between' && <span className="and-text">and</span>}
      {['less-than', 'between'].includes(operator) && (
        <Select
          className="small-custom-react-select"
          clearable
          onChange={(val) => {
            const newFilter = {
              ...value,
              values: [values[0], val],
            };

            if (typeof val !== 'number') newFilter.values = [];

            updateFilter('rankings', newFilter, { panelKey })();
          }}
          options={options}
          searchable={false}
          simpleValue
          value={values[1]}
        />
      )}
    </div>
  );

  let subFilter;

  switch (value.eventType) {
    case 'rank':
      subFilter = (
        <div className="sub-filter-group">
          {rangeOperator}
          {numberRange}
        </div>
      );
      break;
    case 'trend':
      subFilter = (
        <div className="sub-filter-group">
          <Select
            className="trend-operator small-custom-react-select"
            clearable={false}
            onChange={(val) => {
              const newVal = {
                ...value,
                trendOperator: val,
              };

              updateFilter('rankings', newVal, { panelKey })();
            }}
            options={trendOptions}
            searchable={false}
            simpleValue
            value={trendOperator}
          />
          {rangeOperator}
          {numberRange}
          <div className="and-text">
            places in the past
          </div>
          <Select
            className="trend-date small-custom-react-select"
            onChange={(val) => {
              const newVal = {
                ...value,
                dateRange: val,
              };

              updateFilter('rankings', newVal, { panelKey })();
            }}
            options={[
              { value: 'one-week', label: 'Week' },
              { value: 'one-month', label: 'Month' },
            ]}
            searchable={false}
            simpleValue
            value={dateRange || 'one-week'}
          />
        </div>
      );
      break;
    case 'newcomer':
      subFilter = (
        <div className="sub-filter-group">
          <div className="and-text">
            in the last
          </div>
          <Select
            className="newcomer-date small-custom-react-select"
            onChange={(val) => {
              const newVal = {
                ...value,
                dateRange: val,
              };

              updateFilter('rankings', newVal, { panelKey })();
            }}
            options={[
              { value: 'one-day', label: 'Day' },
              { value: 'two-day', label: ' Two Days' },
              { value: 'three-day', label: ' Three Days' },
              { value: 'one-week', label: ' Week' },
              { value: 'one-month', label: ' Month' },
            ]}
            searchable={false}
            simpleValue
            value={dateRange}
          />
        </div>
      );
  }

  return (
    <div className="rankings-filter-group">
      <div className="rankings-eventType">
        Apps that
        <Select
          className="event-type-select small-custom-react-select"
          onChange={(val) => {
            let newVal = {
              ...value,
              eventType: val,
            };

            if (!val) newVal = null;

            updateFilter('rankings', newVal, { panelKey })();
          }}
          options={eventTypeOptions}
          searchable={false}
          simpleValue
          value={eventType}
        />
      </div>
      {subFilter}
    </div>
  );
};

RankingsFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.object,
  }),
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
};

RankingsFilter.defaultProps = {
  filter: {
    value: {
      operator: 'more-than',
      values: [],
      trendOperator: 'up',
      dateRange: 'one-week',
    },
  },
};

export default RankingsFilter;
