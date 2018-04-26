import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';

import CategoriesFilter from '../CategoriesFilter.component';

const ChartsFilter = ({
  filter: {
    value,
  },
  rankingsCountries,
  updateFilter,
  panelKey,
  ...rest
}) => {
  if (!value.eventType) {
    return null;
  }

  return (
    <div className="charts-filter-group" id="charts-filter-group">
      {/* on the following charts: */}
      <ul className="panel-filters list-unstyled">
        <li className="li-filter">
          <label className="filter-label">
            Charts
          </label>
          <div className="input-group ratings-count">
            <Select
              multi
              onChange={(vals) => {
                const newVal = {
                  ...value,
                  charts: vals,
                };

                updateFilter('rankings', newVal, { panelKey })();
              }}
              options={[
                { value: 'free', label: 'Free' },
                { value: 'paid', label: 'Paid' },
                { value: 'grossing', label: 'Grossing' },
              ]}
              searchable={false}
              simpleValue
              value={value.charts}
            />
          </div>
        </li>
        <CategoriesFilter
          androidFilter={value.androidCategories}
          iosFilter={value.iosCategories}
          onCategoryUpdate={platform => (vals) => {
            const newVal = {
              ...value,
              [`${platform}Categories`]: vals,
            };

            updateFilter('rankings', newVal, { panelKey })();
          }}
          panelKey={panelKey}
          {...rest}
        />
        <li className="li-filter">
          <label className="filter-label">
            Countries
          </label>
          <div className="input-group chart-countries">
            <div className="li-select">
              <Select
                closeOnSelect={false}
                multi
                onChange={(values) => {
                  const newVal = {
                    ...value,
                    countries: values,
                  };

                  updateFilter('rankings', newVal, { panelKey })();
                }}
                options={rankingsCountries.map(x => ({ value: x.id, label: x.name }))}
                simpleValue
                value={value.countries}
              />
            </div>
          </div>
        </li>
      </ul>
    </div>
  );
};

ChartsFilter.propTypes = {
  filter: PropTypes.object,
  rankingsCountries: PropTypes.array.isRequired,
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
};

ChartsFilter.defaultProps = {
  filter: {
    value: {
      countries: [],
      iosCategories: [],
      androidCategories: [],
      charts: [],
    },
  },
};

export default ChartsFilter;
