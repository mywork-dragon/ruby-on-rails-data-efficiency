import React from 'react';
import PropTypes from 'prop-types';
import Table from 'components/table/Table.container';
import { headerNames } from 'components/table/redux/column.models';
import Select from 'components/select/CustomSelect.component';
import NoDataMessage from 'Messaging/NoData.component';
import LoadingSpinner from 'Messaging/LoadingSpinner.component';
import RankingsChart from './RankingsChart.component';

const RankingsTab = ({
  charts,
  error,
  errorMessage,
  loaded,
  platform,
  countryOptions,
  categoryOptions,
  isChartDataLoaded,
  isChartDataLoading,
  needAppCategories,
  needRankingsCountries,
  rankingTypeOptions,
  requestAppCategories,
  requestChartData,
  requestRankingsCountries,
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
  if (needAppCategories) requestAppCategories();
  if (needRankingsCountries) requestRankingsCountries();

  if (!isChartDataLoaded && !isChartDataLoading) requestChartData();

  if (!loaded) {
    return (
      <div className="ad-intel-spinner-ctnr">
        <LoadingSpinner />
      </div>
    );
  }

  let content;
  if (isChartDataLoading) {
    content = (
      <div className="ad-intel-spinner-ctnr">
        <LoadingSpinner />
      </div>
    );
  } else if (!isChartDataLoading) {
    if (charts.length) {
      const columns = {
        [headerNames.COLOR]: true,
        [headerNames.COUNTRY]: true,
        [headerNames.RANKING_TYPE]: true,
        [headerNames.CATEGORY]: true,
        [headerNames.SIMPLE_RANK]: true,
        [headerNames.SIMPLE_WEEK_CHANGE]: true,
        [headerNames.SIMPLE_MONTH_CHANGE]: true,
      };

      content = (
        <div>
          <RankingsChart
            chartData={charts}
            isChartDataLoading={isChartDataLoading}
            {...rest}
          />
          <div className="rankings-table-container">
            <Table
              columns={columns}
              pageSize={charts.length}
              platform={platform}
              results={charts}
              resultsCount={charts.length}
              showHeader={false}
              showPagination={false}
            />
          </div>
        </div>
      );
    } else if (error) {
      content = (
        <NoDataMessage>
          {errorMessage || 'Whoops! There was a problem fetching data for this app'}
        </NoDataMessage>
      );
    } else {
      content = (
        <NoDataMessage>
          No Rankings Data
        </NoDataMessage>
      );
    }
  }

  return (
    <div id="appPage">
      <div className="col-md-12 info-column">
        <div className="pull-right rankings-help-link">
          <a href="https://support.mightysignal.com/article/90-historical-app-rankings">How to use App Rankings</a>
        </div>
        <div className="rankings-filter-container">
          <Select
            className="rankings-tab-country-select"
            maxItems={5}
            maxText="A maximum of five countries can be selected"
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
        {content}
      </div>
    </div>
  );
};

RankingsTab.propTypes = {
  error: PropTypes.bool.isRequired,
  errorMessage: PropTypes.string,
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
  isChartDataLoaded: PropTypes.bool.isRequired,
  isChartDataLoading: PropTypes.bool.isRequired,
  needAppCategories: PropTypes.bool.isRequired,
  needRankingsCountries: PropTypes.bool.isRequired,
  rankingTypeOptions: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
  requestAppCategories: PropTypes.func.isRequired,
  requestChartData: PropTypes.func.isRequired,
  requestRankingsCountries: PropTypes.func.isRequired,
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
  errorMessage: 'Whoops! There was a problem fetching data for this app',
  rankingTypeOptions: [],
};

export default RankingsTab;
