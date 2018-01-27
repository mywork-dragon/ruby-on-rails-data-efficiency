import { createAdIntelTabActionTypes, createAdIntelTabActions } from 'components/ad-intel-tab/redux/AdIntelTab.actions';
import { createTableActionTypes, createTableActions } from 'Table/redux/Table.actions';

export const PUBLISHER_AD_INTEL_ACTION_TYPES = createAdIntelTabActionTypes('publisher');
export const publisherAdIntelActions = createAdIntelTabActions(PUBLISHER_AD_INTEL_ACTION_TYPES);

export const PUB_AD_INTEL_TABLE_ACTION_TYPES = createTableActionTypes('publisher/adIntelligence');
export const pubAdIntelTableActions = createTableActions(PUB_AD_INTEL_TABLE_ACTION_TYPES);
