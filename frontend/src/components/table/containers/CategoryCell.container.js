import { connect } from 'react-redux';
import * as appStoreSelectors from 'selectors/appStore.selectors';
import { categories } from 'actions/AppStore.actions';
import CategoryCell from '../components/cells/CategoryCell.component';

const mapDispatchToProps = dispatch => ({
  requestCategories: () => dispatch(categories.request()),
});

const mapStateToProps = state => ({
  shouldFetchCategories: appStoreSelectors.needAppCategories(state),
  getCategoryById: (id, platform) => appStoreSelectors.getCategoryNameById(state, id, platform),
});

const CategoryCellContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(CategoryCell);

export default CategoryCellContainer;
