import { createAdIntelTabActionTypes, createAdIntelTabActions } from 'components/ad-intel-tab/redux/AdIntelTab.actions';
import { createAppTableActionTypes, createAppTableActions } from 'components/app-table/redux/AppTable.actions';

export const PUBLISHER_AD_INTEL_ACTION_TYPES = createAdIntelTabActionTypes('publisher');
export const publisherAdIntelActions = createAdIntelTabActions(PUBLISHER_AD_INTEL_ACTION_TYPES);

export const PUB_AD_INTEL_APP_TABLE_ACTION_TYPES = createAppTableActionTypes('publisher/adIntelligence');
export const pubAdIntelAppTableActions = createAppTableActions(PUB_AD_INTEL_APP_TABLE_ACTION_TYPES);
