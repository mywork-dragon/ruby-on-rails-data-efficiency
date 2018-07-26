import { connect } from 'react-redux';
import moment from 'moment';
import * as rankingsSelectors from 'selectors/rankingsTab.selectors';
import * as appStoreSelectors from 'selectors/appStore.selectors';
import * as appStoreActions from 'actions/AppStore.actions';
import { capitalize, daysAgo } from 'utils/format.utils';
import { getChartColor, googleChartColors, fillRankingsGaps } from 'utils/chart.utils';
import * as actions from './redux/RankingsTab.actions';
import RankingsTab from './RankingsTab.component';

const mapDispatchToProps = dispatch => ({
  updateCountriesFilter: countries => dispatch(actions.updateCountriesFilter(countries)),
  updateCategoriesFilter: categories => dispatch(actions.updateCategoriesFilter(categories)),
  updateAppInfo: (id, platform, appIdentifier) => dispatch(actions.updateAppInfo(id, platform, appIdentifier)),
  updateRankingTypesFilter: types => dispatch(actions.updateRankingTypesFilter(types)),
  updateDateRange: value => dispatch(actions.updateDateRange(value)),
  requestChartData: () => dispatch(actions.rankingsChart.request()),
  requestAppCategories: () => dispatch(appStoreActions.categories.request()),
  requestRankingsCountries: () => dispatch(appStoreActions.rankingsCountries.request()),
  trackTableSort: (field, order) => dispatch(actions.updateTableSort(field, order)),
});

const mapStateToProps = (state, props) => {
  const rankings = props.rankings || [];
  const chartData = rankingsSelectors.getChartData(state);
  const selectedDateRange = rankingsSelectors.getSelectedDateRange(state);
  const charts = chartData.map((x, idx) => {
    const rankingsChart = rankings.find(y => y.country === x.country && y.category === x.category && y.ranking_type === x.rank_type) || {};
    const days = daysAgo(x.ranks[x.ranks.length - 1][0]);
    if (days && rankingsChart.rank) {
      x.ranks.push([moment().format('YYYY-MM-DD'), rankingsChart.rank]);
    }

    return {
      ...x,
      ranks: fillRankingsGaps(x.ranks, selectedDateRange.value),
      platform: props.platform,
      weekly_change: rankingsChart.weekly_change,
      monthly_change: rankingsChart.monthly_change,
      rank: rankingsChart.rank,
      color: getChartColor(idx),
    };
  });

  // prep options
  let rankingTypeOptions = new Set();
  let categoryOptions = new Set();
  rankings.forEach((x) => {
    rankingTypeOptions.add(x.ranking_type);
    categoryOptions.add(x.category);
  });

  // format ranking type options
  rankingTypeOptions = [...rankingTypeOptions].map(x => ({ value: x, label: capitalize(x) }));

  // format country options
  const countryOptions = appStoreSelectors.getRankingsCountries(state)
    .filter(x => x.platforms.includes(props.platform))
    .map(x => ({ value: x.id, label: x.name }));

  // format category options
  const getCategoryNameById = id => appStoreSelectors.getCategoryNameById(state, id, props.platform).name;
  categoryOptions = [...categoryOptions].map(x => ({ value: x, label: getCategoryNameById(x) }));

  return {
    appIdentifier: props.appIdentifier,
    categoryOptions,
    charts,
    colors: googleChartColors,
    countryOptions,
    currentId: rankingsSelectors.getCurrentId(state),
    currentPlatform: rankingsSelectors.getCurrentPlatform(state),
    error: rankingsSelectors.hasRankingsError(state),
    errorMessage: rankingsSelectors.getErrorMessage(state),
    getCategoryNameById,
    isChartDataLoading: rankingsSelectors.isChartDataLoading(state),
    isChartDataLoaded: rankingsSelectors.isChartDataLoaded(state),
    loaded: props.loaded,
    needAppCategories: appStoreSelectors.needAppCategories(state),
    needRankingsCountries: appStoreSelectors.needRankingsCountries(state),
    propsId: props.itemId,
    platform: props.platform,
    rankingTypeOptions,
    selectedCountries: rankingsSelectors.getSelectedCountries(state),
    selectedCategories: rankingsSelectors.getSelectedCategories(state),
    selectedRankingTypes: rankingsSelectors.getSelectedRankingTypes(state),
    selectedDateRange,
  };
};

const mergeProps = (stateProps, dispatchProps) => {
  const {
    currentId,
    propsId,
    currentPlatform,
    appIdentifier,
    ...rest
  } = stateProps;
  const { updateAppInfo, ...other } = dispatchProps;

  if (propsId !== currentId || rest.platform !== currentPlatform) updateAppInfo(propsId, rest.platform, appIdentifier);

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
