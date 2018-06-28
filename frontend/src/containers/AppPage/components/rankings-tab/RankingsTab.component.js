import React from 'react';
import PropTypes from 'prop-types';
import Table from 'components/table/Table.container';
import { headerNames } from 'components/table/redux/column.models';
import Select from 'components/select/CustomSelect.component';
import NoDataMessage from 'Messaging/NoData.component';

const RankingsTab = ({
  charts,
  platform,
  countryOptions,
  categoryOptions,
  selectedCountries,
  selectedCategories,
  updateCountriesFilter,
  updateCategoriesFilter,
}) => {
  const columns = {
    [headerNames.COUNTRY]: true,
    [headerNames.CATEGORY]: true,
    [headerNames.SIMPLE_RANK]: true,
    [headerNames.SIMPLE_WEEK_CHANGE]: true,
    [headerNames.SIMPLE_MONTH_CHANGE]: true,
    [headerNames.SIMPLE_ENTERED_CHART]: true,
  };

  return (
    <div id="appPage">
      <div className="col-md-12 info-column">
        <div className="rankings-filter-container">
          <Select
            className="rankings-tab-country-select"
            multi
            onChange={vals => updateCountriesFilter(vals)}
            options={countryOptions}
            placeholder="Filter countries..."
            simpleValue
            value={selectedCountries}
          />
          <Select
            className="rankings-tab-category-select"
            multi
            onChange={vals => updateCategoriesFilter(vals)}
            options={categoryOptions}
            placeholder="Filter categories..."
            simpleValue
            value={selectedCategories}
          />
        </div>
        { charts.length ? (
          <Table
            columns={columns}
            pageSize={charts.length}
            platform={platform}
            results={charts}
            resultsCount={charts.length}
            showHeader={false}
            showPagination={false}
          />
        ) : (
          <NoDataMessage>
            No Rankings Data
          </NoDataMessage>
        )}
      </div>
    </div>
  );
};

RankingsTab.propTypes = {
  platform: PropTypes.string.isRequired,
  charts: PropTypes.arrayOf(PropTypes.object),
  countryOptions: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
  categoryOptions: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
  updateCountriesFilter: PropTypes.func.isRequired,
  updateCategoriesFilter: PropTypes.func.isRequired,
  selectedCountries: PropTypes.string.isRequired,
  selectedCategories: PropTypes.string.isRequired,
};

RankingsTab.defaultProps = {
  charts: [],
  countryOptions: [],
  categoryOptions: [],
};

export default RankingsTab;
