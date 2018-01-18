import { connect } from 'react-redux';
import { fetchLists } from 'actions/List.actions';
import AdIntelTabComponent from 'components/ad-intel-tab/AdIntelTab.component';
import { publisherAdIntelActions, pubAdIntelAppTableActions } from '../redux/Publisher.actions';

const mapDispatchToProps = (dispatch, ownProps) => ({
  requestCreatives: params => dispatch(publisherAdIntelActions.requestCreatives(
    ownProps.itemId,
    ownProps.platform,
    params,
  )),
  requestInfo: () => dispatch(publisherAdIntelActions.requestAdIntelInfo(
    ownProps.itemId,
    ownProps.platform,
  )),
  requestLists: () => dispatch(fetchLists()),
  toggleFilter: (value, type) => dispatch(publisherAdIntelActions.toggleCreativeFilter(value, type)),
  updateIndex: index => dispatch(publisherAdIntelActions.updateActiveCreativeIndex(index)),
  toggleItem: (id, type) => dispatch(pubAdIntelAppTableActions.toggleItem({ id, type })),
  toggleAll: () => dispatch(pubAdIntelAppTableActions.toggleAllItems()),
});

const mapStateToProps = (store, ownProps) => {
  const adIntel = store.publisher.adIntelligence;
  const info = adIntel.info;
  const isLoaded = info.id === ownProps.itemId && info.platform === ownProps.platform;
  const noData = isLoaded && info.ad_networks.length === 0;
  const loadError = info.loadError;
  const listsLoaded = store.lists.loaded;
  const listsFetching = store.lists.fetching;
  const appTable = store.publisher.adIntelligence.appTable;

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
    listsFetching,
    adIntel,
    type: 'publisher',
    ...appTable,
    showAppsTable: true,
  };
  return res;
};

const PublisherIntelTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdIntelTabComponent);

export default PublisherIntelTabContainer;
