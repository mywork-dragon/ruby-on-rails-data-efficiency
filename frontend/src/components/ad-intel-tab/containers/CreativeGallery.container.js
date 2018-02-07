import { connect } from 'react-redux';

import CreativeGalleryComponent from '../components/CreativeGallery.component';

const mapDispatchToProps = (dispatch, ownProps) => ({
  ...ownProps,
});

const mapStateToProps = (store, { adIntel: { info, creatives }, itemId }) => {
  const activeCreative = creatives.results[creatives.activeIndex];
  const isLoaded = itemId === creatives.id;

  const res = {
    ...creatives,
    activeCreative,
    advertisingApps: info.advertising_apps,
    formats: info.creative_formats,
    hasCreatives: info.number_of_creatives !== 0,
    id: info.id,
    isLoaded,
    networks: info.ad_networks,
    platform: info.platform,
    totalCount: creatives.resultsCount,
  };

  return res;
};

const mergeProps = (storeProps, dispatchProps) => {
  const {
    activeFormats,
    activeNetworks,
    pageSize,
  } = storeProps;

  const getCreatives = () => {
    dispatchProps.requestCreatives({
      pageNum: 1,
      pageSize,
      formats: activeFormats,
      networks: activeNetworks,
    });
  };

  return {
    ...storeProps,
    ...dispatchProps,
    getCreatives,
  };
};

const CreativeGalleryContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(CreativeGalleryComponent);

export default CreativeGalleryContainer;
