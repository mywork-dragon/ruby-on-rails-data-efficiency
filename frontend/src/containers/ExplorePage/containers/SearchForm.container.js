import { connect } from 'react-redux';
import SearchForm from '../components/SearchForm.component';
import { tableActions } from '../redux/Explore.actions';

const mapDispatchToProps = dispatch => ({
  clearFilters: () => () => dispatch(tableActions.clearFilters()),
  requestResults: params => dispatch(tableActions.allItems.request(params)),
  updateFilter: (parameter, value) => () => dispatch(tableActions.updateFilter(parameter, value)),
});

const mapStateToProps = ({ explorePage: { searchForm } }) => ({
  ...searchForm,
});

const SearchFormContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(SearchForm);

export default SearchFormContainer;
