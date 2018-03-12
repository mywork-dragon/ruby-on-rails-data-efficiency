import { action, createRequestTypes } from 'utils/action.utils';

export const AD_NETWORKS = createRequestTypes('AD_NETWORKS');
export const adNetworks = {
  request: () => action(AD_NETWORKS.REQUEST),
  success: networks => action(AD_NETWORKS.SUCCESS, { networks }),
  failure: () => action(AD_NETWORKS.FAILURE),
};
