import React from 'react';
import PropTypes from 'prop-types';
import Select from 'components/select/CustomSelect.component';
import { formatCategoriesForSelect } from 'utils/explore/general.utils';

import CategoriesFilter from '../CategoriesFilter.component';

const ChartsFilter = ({
  filter: {
    value,
  },
  rankingsCountries,
  updateFilter,
  panelKey,
  iosCategories,
  androidCategories,
  ...rest
}) => {
  if (!value.eventType) {
    return null;
  }

  return (
    <div className="charts-filter-group" id="charts-filter-group">
      <ul className="panel-filters list-unstyled">
        <li className="li-filter">
          <label className="filter-label">
            On the following charts:
          </label>
          <div className="input-group">
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
              placeholder="Any chart"
              searchable={false}
              simpleValue
              value={value.charts}
            />
          </div>
        </li>
        <CategoriesFilter
          onCategoryUpdate={(vals) => {
            const newVal = {
              ...value,
              categories: vals,
            };

            updateFilter('rankings', newVal, { panelKey })();
          }}
          options={formatCategoriesForSelect(iosCategories, androidCategories, rest.platform)}
          panelKey={panelKey}
          placeholder="Any category"
          title="In the following categories:"
          value={value.categories}
          {...rest}
        />
        <li className="li-filter">
          <label className="filter-label">
            In the following countries:
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
                placeholder="Any country"
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
  iosCategories: PropTypes.arrayOf(PropTypes.object),
  androidCategories: PropTypes.arrayOf(PropTypes.object),
};

ChartsFilter.defaultProps = {
  filter: {
    value: {
      countries: 'US',
      categories: [{ value: 'Overall', label: 'Overall', ios: '36', android: 'OVERALL' }],
      charts: 'free',
    },
  },
  iosCategories: [],
  androidCategories: [],
};

export default ChartsFilter;
