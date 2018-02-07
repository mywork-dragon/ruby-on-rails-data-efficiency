import { connect } from 'react-redux';
import { addSelectedToList, fetchLists } from 'actions/List.actions';

import ListDropdownComponent from '../components/ListDropdown.component';

const mapDispatchToProps = (dispatch, { selectedItems }) => ({
  addToList: id => dispatch(addSelectedToList(id, selectedItems)),
  requestLists: () => dispatch(fetchLists()),
});

const mapStateToProps = ({ lists }, { selectedItems }) => ({
  fetching: lists.fetching,
  empty: selectedItems.length === 0,
  lists: lists.lists,
  loaded: lists.loaded,
  selectedItems,
});

const ListDropdownContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(ListDropdownComponent);

export default ListDropdownContainer;
