import React from 'react';
import PropTypes from 'prop-types';

const ListDropdownComponent = ({
  addToList,
  empty,
  lists,
  loaded,
  requestLists,
}) => {
  if (!loaded) {
    requestLists();
  }

  const handleChange = event => addToList(event.target.value);

  return (
    <span className="ui-select pull-right">
      <select disabled={empty} id="addSelectedToDropDown" onChange={handleChange}>
        <option value="">Add Selected To List</option>
        { lists.map(list => <option key={list.id} value={list.id}>{list.name}</option>) }
      </select>
    </span>
  );
};

ListDropdownComponent.propTypes = {
  addToList: PropTypes.func.isRequired,
  empty: PropTypes.bool.isRequired,
  lists: PropTypes.arrayOf(PropTypes.object).isRequired,
  loaded: PropTypes.bool.isRequired,
  requestLists: PropTypes.func.isRequired,
};

export default ListDropdownComponent;
