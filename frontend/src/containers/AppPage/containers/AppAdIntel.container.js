import { connect } from 'react-redux';
import AdIntelTabComponent from 'components/ad-intel-tab/AdIntelTab.component';
import { adIntelActions } from '../redux/App.actions';

const mapDispatchToProps = (dispatch, { itemId, platform }) => ({
  requestCreatives: params => dispatch(adIntelActions.creatives.request(
    itemId,
    platform,
    params,
  )),
  requestInfo: () => dispatch(adIntelActions.adIntelInfo.request(
    itemId,
    platform,
  )),
  toggleFilter: (value, type) => dispatch(adIntelActions.toggleCreativeFilter(value, type)),
  updateIndex: index => dispatch(adIntelActions.updateActiveCreativeIndex(index)),
});

const mapStateToProps = ({ appPage: { adIntelligence } }, { itemId, platform }) => {
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
    type: 'app',
  };
  return res;
};

const AppAdIntelTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdIntelTabComponent);

export default AppAdIntelTabContainer;
