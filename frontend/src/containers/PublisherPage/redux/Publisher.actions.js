import {
  createTableActionTypes,
  createTableRequestTypes,
  createTableActions,
  createTableRequestActions,
} from 'Table/redux/Table.actions';

import {
  createAdIntelTabActionTypes,
  createAdIntelTabRequestTypes,
  createAdIntelTabActions,
  createAdIntelTabRequestActions,
} from 'components/ad-intel-tab/redux/AdIntelTab.actions';

export const PUBLISHER_AD_INTEL_ACTION_TYPES = createAdIntelTabActionTypes('publisherPage');
export const publisherAdIntelActions = createAdIntelTabActions(PUBLISHER_AD_INTEL_ACTION_TYPES);

export const PUBLISHER_AD_INTEL_REQUEST_TYPES = createAdIntelTabRequestTypes('publisherPage');
export const publisherAdIntelRequestActions = createAdIntelTabRequestActions(PUBLISHER_AD_INTEL_REQUEST_TYPES);

export const AD_INTEL_TYPES = Object.assign({}, PUBLISHER_AD_INTEL_ACTION_TYPES, PUBLISHER_AD_INTEL_REQUEST_TYPES);
export const adIntelActions = Object.assign({}, publisherAdIntelActions, publisherAdIntelRequestActions);

export const PUB_AD_INTEL_TABLE_ACTION_TYPES = createTableActionTypes('publisherPage/adIntelligence');
export const pubAdIntelTableActions = createTableActions(PUB_AD_INTEL_TABLE_ACTION_TYPES);

export const PUB_AD_INTEL_TABLE_REQUEST_TYPES = createTableRequestTypes('publisherPage/adIntelligence');
export const pubAdIntelTableRequestActions = createTableRequestActions(PUB_AD_INTEL_TABLE_REQUEST_TYPES);

export const TABLE_TYPES = Object.assign({}, PUB_AD_INTEL_TABLE_ACTION_TYPES, PUB_AD_INTEL_TABLE_REQUEST_TYPES);
export const tableActions = Object.assign({}, pubAdIntelTableActions, pubAdIntelTableRequestActions);
