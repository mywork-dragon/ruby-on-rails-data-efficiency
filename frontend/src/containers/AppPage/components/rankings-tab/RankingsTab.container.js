import _ from 'lodash';
import { connect } from 'react-redux';
import { getCountryById, getCategoryNameById } from 'selectors/appStore.selectors';
import { capitalize } from 'utils/format.utils';
import * as actions from './redux/RankingsTab.actions';
import RankingsTab from './RankingsTab.component';

const mapDispatchToProps = dispatch => ({
  updateCountriesFilter: countries => dispatch(actions.updateCountriesFilter(countries)),
  updateCategoriesFilter: categories => dispatch(actions.updateCategoriesFilter(categories)),
  updateId: id => dispatch(actions.updateId(id)),
  updateRankingTypesFilter: types => dispatch(actions.updateRankingTypesFilter(types)),
});

const mapStateToProps = (state, props) => {
  const currentId = state.appPage.rankings.id;
  const selectedCountries = state.appPage.rankings.selectedCountries;
  const selectedCategories = state.appPage.rankings.selectedCategories;
  const selectedRankingTypes = state.appPage.rankings.selectedRankingTypes;
  let countryOptions = [];
  let categoryOptions = [];
  let rankingTypeOptions = [];

  const rankings = props.rankings || [];

  const charts = rankings.map((x) => {
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
    (!selectedCountries.length || selectedCountries.includes(x.country)) &&
    (!selectedCategories.length || selectedCategories.includes(x.category)) &&
    (!selectedRankingTypes.length || selectedRankingTypes.includes(x.ranking_type)));

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

  return {
    propsId: props.itemId,
    currentId,
    selectedCountries,
    selectedCategories,
    selectedRankingTypes,
    countryOptions,
    charts,
    categoryOptions,
    rankingTypeOptions,
    platform: props.platform,
  };
};

const mergeProps = (stateProps, dispatchProps) => {
  const { currentId, propsId, ...rest } = stateProps;
  const { updateId, ...other } = dispatchProps;

  if (propsId !== currentId) updateId(propsId);

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
