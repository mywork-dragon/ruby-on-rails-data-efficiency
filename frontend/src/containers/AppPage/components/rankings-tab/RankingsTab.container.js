import _ from 'lodash';
import { connect } from 'react-redux';
import { getCountryById, getCategoryNameById } from 'selectors/appStore.selectors';
import * as rankingsSelectors from 'selectors/rankingsTab.selectors';
import { capitalize } from 'utils/format.utils';
import { getChartColor, googleChartColors } from 'utils/chart.utils';
import * as actions from './redux/RankingsTab.actions';
import RankingsTab from './RankingsTab.component';

const mapDispatchToProps = dispatch => ({
  updateCountriesFilter: countries => dispatch(actions.updateCountriesFilter(countries)),
  updateCategoriesFilter: categories => dispatch(actions.updateCategoriesFilter(categories)),
  updateId: (id, platform) => dispatch(actions.updateId(id, platform)),
  updateRankingTypesFilter: types => dispatch(actions.updateRankingTypesFilter(types)),
  updateDateRange: value => dispatch(actions.updateDateRange(value)),
  requestChartData: () => dispatch(actions.rankingsChart.request()),
});

const mapStateToProps = (state, props) => {
  const currentId = rankingsSelectors.getCurrentId(state);
  const selectedCountries = rankingsSelectors.getSelectedCountries(state);
  const selectedCategories = rankingsSelectors.getSelectedCategories(state);
  const selectedRankingTypes = rankingsSelectors.getSelectedRankingTypes(state);
  const selectedDateRange = rankingsSelectors.getSelectedDateRange(state);
  let countryOptions = [];
  let categoryOptions = [];
  let rankingTypeOptions = [];

  const rankings = props.rankings || [];

  let charts = rankings.map((x) => {
    countryOptions.push(x.country);
    categoryOptions.push(x.category);
    rankingTypeOptions.push(x.ranking_type);
    const newcomerChart = props.newcomers.find(y => y.category === x.category && y.country === x.country && y.ranking_type === x.ranking_type);
    const date = newcomerChart ? newcomerChart.date : null;

    return {
      ...x,
      date,
      platform: props.platform,
    };
  }).filter(x =>
    (selectedCountries.map(i => i.value).join(',').includes(x.country)) &&
    (!selectedCategories.length || selectedCategories.includes(x.category)) &&
    (!selectedRankingTypes.length || selectedRankingTypes.includes(x.ranking_type)));

  charts = charts.map((x, idx) => ({ ...x, color: getChartColor(idx) }));

  countryOptions = _.sortBy(_.uniq(countryOptions).map((x) => {
    const country = getCountryById(state, x);
    return {
      value: x,
      label: country ? country.name : x,
    };
  }), x => x.label);

  categoryOptions = _.sortBy(_.uniq(categoryOptions).map((x) => {
    const category = getCategoryNameById(state, x, props.platform);
    return {
      value: x,
      label: category ? category.name : x,
    };
  }), x => x.label);

  rankingTypeOptions = _.sortBy(_.uniq(rankingTypeOptions).map(x => ({
    value: x,
    label: capitalize(x),
  })), x => x.label);

  // eventually should not need to filter
  let chartData = rankingsSelectors.getChartData(state).filter(x =>
    (selectedCountries.map(i => i.value).join(',').includes(x.info.country_code)) &&
    (!selectedCategories.length || selectedCategories.includes(x.info.category)) &&
    (!selectedRankingTypes.length || selectedRankingTypes.includes(x.info.rank_type)));

  chartData = _.sortBy(chartData, x => charts.findIndex(y => y.country === x.info.country_code && y.ranking_type === x.info.rank_type && y.category === x.info.category));

  return {
    propsId: props.itemId,
    loaded: props.loaded,
    currentId,
    selectedCountries,
    selectedCategories,
    selectedRankingTypes,
    selectedDateRange,
    countryOptions,
    charts,
    categoryOptions,
    rankingTypeOptions,
    platform: props.platform,
    chartData,
    isChartDataLoading: rankingsSelectors.isChartDataLoading(state),
    isChartDataLoaded: rankingsSelectors.isChartDataLoaded(state),
    getCategoryNameById: id => getCategoryNameById(state, id, props.platform).name,
    colors: googleChartColors,
  };
};

const mergeProps = (stateProps, dispatchProps) => {
  const { currentId, propsId, ...rest } = stateProps;
  const { updateId, ...other } = dispatchProps;

  if (propsId !== currentId) updateId(propsId, rest.platform);

  return {
    ...rest,
    ...other,
  };
};

const RankingsTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(RankingsTab);

export default RankingsTabContainer;
