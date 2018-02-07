import { connect } from 'react-redux';
import AdIntelTabComponent from 'components/ad-intel-tab/AdIntelTab.component';
import { publisherAdIntelActions, publisherAdIntelRequestActions } from '../redux/Publisher.actions';

const mapDispatchToProps = (dispatch, { itemId, platform }) => ({
  requestCreatives: params => dispatch(publisherAdIntelRequestActions.creatives.request(
    itemId,
    platform,
    params,
  )),
  requestInfo: () => dispatch(publisherAdIntelRequestActions.adIntelInfo.request(
    itemId,
    platform,
  )),
  toggleFilter: (value, type) => dispatch(publisherAdIntelActions.toggleCreativeFilter(value, type)),
  updateIndex: index => dispatch(publisherAdIntelActions.updateActiveCreativeIndex(index)),
});

const mapStateToProps = ({ publisherPage: { adIntelligence } }, { itemId, platform }) => {
  const info = adIntelligence.info;
  const isLoaded = info.id === itemId && info.platform === platform;
  const noData = isLoaded && info.ad_networks.length === 0;
  const loadError = info.loadError;

  if (isLoaded === false) {
    return {
      isLoaded,
    };
  }

  const res = {
    isLoaded,
    noData,
    loadError,
    adIntel: adIntelligence,
    type: 'publisher',
    showAppsTable: true,
  };
  return res;
};

const PublisherIntelTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdIntelTabComponent);

export default PublisherIntelTabContainer;
