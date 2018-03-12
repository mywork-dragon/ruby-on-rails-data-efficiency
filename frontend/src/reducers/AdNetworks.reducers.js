import { AD_NETWORKS } from 'actions/Account.actions';

const initialState = {
  fetching: false,
  loaded: false,
  adNetworks: {},
};

function adNetworks (state = initialState, action) {
  switch (action.type) {
    case AD_NETWORKS.REQUEST:
      return {
        ...state,
        fetching: true,
      };
    case AD_NETWORKS.SUCCESS:
      return loadNetworks(action);
    default:
      return state;
  }
}

function loadNetworks(action) {
  return {
    ...initialState,
    adNetworks: action.payload.networks,
    loaded: true,
  };
}

export default adNetworks;
