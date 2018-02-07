import { connect } from 'react-redux';
import CreativeMixpanelService from 'Mixpanel/creative.mixpanel';

import PaginationComponent from '../components/CreativePagination.component';

const mapDispatchToProps = (dispatch, { requestCreatives }) => ({
  requestCreatives,
});

const mapStateToProps = (store, ownProps) => ({
  ...ownProps,
});

const mergeProps = (storeProps, dispatchProps) => {
  const {
    activeFormats,
    activeNetworks,
    itemId,
    pageNum,
    pageSize,
    platform,
    resultsCount,
    type,
  } = storeProps;

  return {
    requestCreatives: (page) => {
      CreativeMixpanelService(itemId, platform, type).trackCreativePageThrough(page);
      dispatchProps.requestCreatives({
        pageNum: page,
        pageSize,
        formats: activeFormats,
        networks: activeNetworks,
      });
    },
    pageNum,
    pageSize,
    resultsCount,
  };
};

const PaginationContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(PaginationComponent);

export default PaginationContainer;
