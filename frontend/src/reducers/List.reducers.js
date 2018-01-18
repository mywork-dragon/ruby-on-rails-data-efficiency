import {
  FETCH_LISTS,
  LOAD_LISTS,
} from 'actions/List.actions';

const initialState = {
  loaded: false,
  fetching: false,
  lists: [],
};

function lists(state = initialState, action) {
  switch (action.type) {
    case FETCH_LISTS:
      return {
        ...state,
        fetching: true,
      };
    case LOAD_LISTS:
      return loadLists(action);
    default:
      return state;
  }
}

function loadLists(action) {
  return {
    ...initialState,
    ...action.payload,
    loaded: true,
  };
}

export default lists;
