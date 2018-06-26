import { connect } from 'react-redux';
import * as appStoreSelectors from 'selectors/appStore.selectors';
import { rankingsCountries } from 'actions/AppStore.actions';
import CountryCell from '../components/cells/CountryCell.component';

const mapDispatchToProps = dispatch => ({
  requestCountries: () => dispatch(rankingsCountries.request()),
});

const mapStateToProps = state => ({
  shouldFetchCountries: appStoreSelectors.needRankingsCountries(state),
  getCountryById: id => appStoreSelectors.getCountryById(state, id),
});

const CountryCellContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(CountryCell);

export default CountryCellContainer;
