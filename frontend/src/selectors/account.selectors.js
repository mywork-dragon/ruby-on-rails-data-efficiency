export const shouldFetchAdNetworks = state => !state.account.adNetworks.loaded && !state.account.adNetworks.fetching;

export const accessibleNetworks = state => Object.values(state.account.adNetworks.adNetworks).filter(x => x.can_access);

export const isFacebookOnly = state => accessibleNetworks(state).length === 1 && accessibleNetworks(state)[0].id === 'facebook';
