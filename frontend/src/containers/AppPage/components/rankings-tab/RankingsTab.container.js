import _ from 'lodash';
import { connect } from 'react-redux';
import * as rankingsSelectors from 'selectors/rankingsTab.selectors';
import * as appStoreSelectors from 'selectors/appStore.selectors';
import * as appStoreActions from 'actions/AppStore.actions';
import { capitalize } from 'utils/format.utils';
import { getChartColor, googleChartColors } from 'utils/chart.utils';
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
});

const mapStateToProps = (state, props) => {
  const currentId = rankingsSelectors.getCurrentId(state);
  const selectedCountries = rankingsSelectors.getSelectedCountries(state);
  const selectedCategories = rankingsSelectors.getSelectedCategories(state);
  const selectedRankingTypes = rankingsSelectors.getSelectedRankingTypes(state);
  const selectedDateRange = rankingsSelectors.getSelectedDateRange(state);
  const rankings = props.rankings || [];
  const chartData = rankingsSelectors.getChartData(state);

  const charts = chartData.map((x, idx) => {
    const rankingsChart = rankings.find(y => y.country === x.info.country_code && y.category === x.info.category && y.ranking_type === x.info.rank_type) || {};

    return {
      ...x.info,
      ranks: x.ranks,
      platform: props.platform,
      weekly_change: rankingsChart.weekly_change,
      monthly_change: rankingsChart.monthly_change,
      rank: x.ranks[x.ranks.length - 1][1],
      country: x.info.country_code,
      color: getChartColor(idx),
    };
  });

  // format ranking type options
  const rankingTypeOptions = _.uniq(rankings.map(x => x.ranking_type)).map(x => ({ value: x, label: capitalize(x) }));

  // format country options
  const countryOptions = _.sortBy(appStoreSelectors.getRankingsCountries(state).filter(x => x.platforms.includes(props.platform)).map(x => ({ value: x.id, label: x.name })), x => x.label);

  // format category options
  let categoryOptions;
  if (props.platform === 'ios') {
    categoryOptions = appStoreSelectors.getIosCategories(state).filter(x => ['Overall', ...props.categories].includes(x.name));
  } else {
    categoryOptions = appStoreSelectors.getAndroidCategories(state).filter(x => ['Overall', ...props.categories].includes(x.name));
  }
  categoryOptions = categoryOptions.map(x => ({ value: x.id, label: x.name }));

  return {
    propsId: props.itemId,
    currentPlatform: rankingsSelectors.getCurrentPlatform(state),
    loaded: props.loaded,
    appIdentifier: props.appIdentifier,
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
    isChartDataLoading: rankingsSelectors.isChartDataLoading(state),
    isChartDataLoaded: rankingsSelectors.isChartDataLoaded(state),
    getCategoryNameById: id => appStoreSelectors.getCategoryNameById(state, id, props.platform).name,
    colors: googleChartColors,
    needAppCategories: appStoreSelectors.needAppCategories(state),
    needRankingsCountries: appStoreSelectors.needRankingsCountries(state),
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
