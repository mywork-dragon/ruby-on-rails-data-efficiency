export const FETCH_AD_NETWORKS = 'FETCH_AD_NETWORKS';
export const LOAD_AD_NETWORKS = 'LOAD_AD_NETWORKS';

export function fetchAdNetworks() {
  return { type: FETCH_AD_NETWORKS };
}

export function loadAdNetworks(networks) {
  return { type: LOAD_AD_NETWORKS, payload: { networks } };
}
