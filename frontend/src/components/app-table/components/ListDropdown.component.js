import React from 'react';
import PropTypes from 'prop-types';

const ListDropdownComponent = ({
  addToList,
  lists,
  empty,
}) => {
  const handleChange = event => addToList(event.target.value);

  return (
    <span className="ui-select pull-right">
      <select id="addSelectedToDropDown" onChange={handleChange} disabled={empty}>
        <option value="">Add Selected To List</option>
        { lists.map(list => <option value={list.id} key={list.id}>{list.name}</option>) }
      </select>
    </span>
  );
};

ListDropdownComponent.propTypes = {
  addToList: PropTypes.func.isRequired,
  lists: PropTypes.arrayOf(PropTypes.object).isRequired,
  empty: PropTypes.bool.isRequired,
};

export default ListDropdownComponent;
