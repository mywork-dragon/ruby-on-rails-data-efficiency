import { connect } from 'react-redux';
import { addSelectedToList, fetchLists } from 'actions/List.actions';

import ListDropdownComponent from '../components/ListDropdown.component';

const mapDispatchToProps = dispatch => ({
  addToList: (id, items) => dispatch(addSelectedToList(id, items)),
  requestLists: () => dispatch(fetchLists()),
});

const mapStateToProps = (store, ownProps) => ({
  lists: store.lists.lists,
  loaded: store.lists.loaded,
  selectedItems: ownProps.selectedItems,
  empty: ownProps.selectedItems.length === 0,
});

const mergeProps = (storeProps, dispatchProps) => ({
  lists: storeProps.lists,
  loaded: storeProps.loaded,
  empty: storeProps.empty,
  addToList: id => dispatchProps.addToList(id, storeProps.selectedItems),
  requestLists: dispatchProps.requestLists,
});

const ListDropdownContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(ListDropdownComponent);

export default ListDropdownContainer;
