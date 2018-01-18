import { connect } from 'react-redux';
import { fetchLists } from 'actions/List.actions';
import AdIntelTabComponent from 'components/ad-intel-tab/AdIntelTab.component';
import { appAdIntelActions } from '../redux/App.actions';

const mapDispatchToProps = (dispatch, ownProps) => ({
  requestCreatives: params => dispatch(appAdIntelActions.requestCreatives(
    ownProps.itemId,
    ownProps.platform,
    params,
  )),
  requestInfo: () => dispatch(appAdIntelActions.requestAdIntelInfo(
    ownProps.itemId,
    ownProps.platform,
  )),
  requestLists: () => dispatch(fetchLists()),
  toggleFilter: (value, type) => dispatch(appAdIntelActions.toggleCreativeFilter(value, type)),
  updateIndex: index => dispatch(appAdIntelActions.updateActiveCreativeIndex(index)),
});

const mapStateToProps = (store, ownProps) => {
  const adIntel = store.app.adIntelligence;
  const info = adIntel.info;
  const isLoaded = info.id === ownProps.itemId && info.platform === ownProps.platform;
  const noData = isLoaded && info.ad_networks.length === 0;
  const loadError = info.loadError;
  const listsLoaded = store.lists.loaded;

  if (isLoaded === false) {
    return {
      isLoaded,
    };
  }

  const res = {
    isLoaded,
    noData,
    loadError,
    listsLoaded,
    adIntel,
    type: 'app',
  };
  return res;
};

const AppAdIntelTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdIntelTabComponent);

export default AppAdIntelTabContainer;
