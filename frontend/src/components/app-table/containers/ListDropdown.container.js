import { connect } from 'react-redux';

import { addSelectedToList } from 'actions/List.actions';

import ListDropdownComponent from '../components/ListDropdown.component';

const mapDispatchToProps = dispatch => ({
  addToList: (id, apps) => dispatch(addSelectedToList(id, apps)),
});

const mapStateToProps = (store, ownProps) => ({
  lists: store.lists.lists,
  selectedApps: ownProps.selectedApps,
  empty: ownProps.selectedApps.length === 0,
});

const mergeProps = (storeProps, dispatchProps) => ({
  lists: storeProps.lists,
  empty: storeProps.empty,
  addToList: id => dispatchProps.addToList(id, storeProps.selectedApps),
});

const ListDropdownContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(ListDropdownComponent);

export default ListDropdownContainer;
