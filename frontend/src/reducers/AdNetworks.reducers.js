import {
  FETCH_AD_NETWORKS,
  LOAD_AD_NETWORKS,
} from 'actions/Account.actions';

const initialState = {
  fetching: false,
  loaded: false,
  adNetworks: {},
};

function adNetworks (state = initialState, action) {
  switch (action.type) {
    case FETCH_AD_NETWORKS:
      return {
        ...state,
        fetching: true,
      };
    case LOAD_AD_NETWORKS:
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
