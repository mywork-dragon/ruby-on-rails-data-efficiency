import React from 'react';
import PropTypes from 'prop-types';
import Table from 'components/table/Table.container';
import { headerNames } from 'components/table/redux/column.models';
import Select from 'components/select/CustomSelect.component';
import NoDataMessage from 'Messaging/NoData.component';
import LoadingSpinner from 'Messaging/LoadingSpinner.component';
import RankingsTable from './RankingsTable.component';

const RankingsTab = ({
  charts,
  loaded,
  platform,
  countryOptions,
  categoryOptions,
  rankingTypeOptions,
  selectedCountries,
  selectedCategories,
  selectedDateRange,
  selectedRankingTypes,
  updateCountriesFilter,
  updateCategoriesFilter,
  updateDateRange,
  updateRankingTypesFilter,
  ...rest
}) => {
  if (!loaded) {
    return (
      <div className="ad-intel-spinner-ctnr">
        <LoadingSpinner />
      </div>
    );
  }

  const columns = {
    [headerNames.COLOR]: true,
    [headerNames.COUNTRY]: true,
    [headerNames.RANKING_TYPE]: true,
    [headerNames.CATEGORY]: true,
    [headerNames.SIMPLE_RANK]: true,
    [headerNames.SIMPLE_WEEK_CHANGE]: true,
    [headerNames.SIMPLE_MONTH_CHANGE]: true,
    [headerNames.SIMPLE_ENTERED_CHART]: true,
  };

  return (
    <div id="appPage">
      <div className="col-md-12 info-column">
        <RankingsTable {...rest} />
        <div className="rankings-filter-container">
          <Select
            className="rankings-tab-country-select"
            maxItems={11}
            multi
            onChange={vals => updateCountriesFilter(vals)}
            options={countryOptions}
            placeholder="Filter countries..."
            value={selectedCountries}
          />
          <Select
            className="rankings-tab-category-select"
            multi
            onChange={vals => updateRankingTypesFilter(vals)}
            options={rankingTypeOptions}
            placeholder="Filter ranking types..."
            simpleValue
            value={selectedRankingTypes}
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
          <Select
            className="rankings-tab-category-select"
            onChange={val => updateDateRange(val)}
            options={[
              { value: 7, label: 'Last Week' },
              { value: 14, label: 'Last Two Weeks' },
              { value: 30, label: 'Last 30 Days' },
              { value: 90, label: 'Last 90 Days' },
            ]}
            value={selectedDateRange}
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
  loaded: PropTypes.bool.isRequired,
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
  rankingTypeOptions: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
  updateCountriesFilter: PropTypes.func.isRequired,
  updateCategoriesFilter: PropTypes.func.isRequired,
  updateDateRange: PropTypes.func.isRequired,
  updateRankingTypesFilter: PropTypes.func.isRequired,
  selectedCountries: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })).isRequired,
  selectedCategories: PropTypes.string.isRequired,
  selectedDateRange: PropTypes.shape({
    value: PropTypes.number,
    label: PropTypes.string,
  }).isRequired,
  selectedRankingTypes: PropTypes.string.isRequired,
};

RankingsTab.defaultProps = {
  charts: [],
  countryOptions: [],
  categoryOptions: [],
  rankingTypeOptions: [],
};

export default RankingsTab;
