import {
  GET_SAVED_SEARCHES,
  SAVE_NEW_SEARCH,
  DELETE_SAVED_SEARCH,
} from 'actions/Account.actions';

const initialState = {
  fetching: false,
  loaded: false,
  searches: {},
};

function savedSearches (state = initialState, action) {
  switch (action.type) {
    case GET_SAVED_SEARCHES.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case GET_SAVED_SEARCHES.SUCCESS:
      return loadSearches(action);
    case SAVE_NEW_SEARCH.SUCCESS:
      return addNewSearch(state, action);
    case DELETE_SAVED_SEARCH.SUCCESS:
      return deleteSearch(state, action);
    default:
      return state;
  }
}

function loadSearches({ payload: { searches } }) {
  const newState = {
    ...initialState,
    searches,
    loaded: true,
  };

  return newState;
}

function addNewSearch(state, { payload: { search } }) {
  const newState = { ...state };
  search.queryId = search.search_params;
  delete search.search_params;
  newState.searches[search.id] = search;

  return newState;
}

function deleteSearch(state, { payload: { id } }) {
  const newState = { ...state };
  delete newState.searches[id];

  return newState;
}

export default savedSearches;
