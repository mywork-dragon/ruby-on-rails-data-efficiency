import {
  LOAD_PERMISSIONS
} from 'actions/Account.actions';

const initialState = {
  fetching: false,
  loaded: false,
  permissions: {}
};

function permissions (state = initialState, action) {
  switch (action.type) {
    case LOAD_PERMISSIONS.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case LOAD_PERMISSIONS.SUCCESS:
      return loadPermissions(action);
    default:
      return state;
  }
}


function loadPermissions({ payload: { data } }) {
  const newState = {
    ...initialState,
    permissions: data,
    loaded: true,
  };

  return newState;
}


export default permissions;
