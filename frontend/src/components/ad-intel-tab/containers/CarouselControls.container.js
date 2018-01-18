import { connect } from 'react-redux';

import CarouselControlsComponent from '../components/CarouselControls.component';

const mapDispatchToProps = (dispatch, ownProps) => ({
  updateIndex: ownProps.updateIndex,
  getCreatives: ownProps.requestCreatives,
});

const mapStateToProps = (store, ownProps) => ({
  activeIndex: ownProps.activeIndex,
  currentSize: ownProps.currentSize,
  format: ownProps.format,
  formats: ownProps.formats,
  networks: ownProps.networks,
  pageNum: ownProps.pageNum,
  pageSize: ownProps.pageSize,
  resultsCount: ownProps.resultsCount,
});

const mergeProps = (storeProps, dispatchProps) => {
  const {
    currentSize,
    formats,
    networks,
    pageNum,
    pageSize,
    resultsCount,
  } = storeProps;

  const totalPages = Math.ceil(resultsCount / pageSize);

  const requestCreatives = (page) => {
    dispatchProps.getCreatives({
      pageNum: page, pageSize, networks, formats,
    });
  };

  const getNextPage = () => {
    if (pageNum < totalPages) {
      requestCreatives(pageNum + 1);
    } else if (pageNum === totalPages) {
      requestCreatives(1);
    }
  };

  const getPreviousPage = () => {
    if (pageNum === 1) {
      requestCreatives(totalPages);
    } else {
      requestCreatives(pageNum - 1);
    }
  };

  const updateIndex = (index) => {
    if (index >= 0 && index < currentSize) {
      dispatchProps.updateIndex(index);
    } else if (index >= currentSize) {
      getNextPage();
      updateIndex(0);
    } else if (index === -1) {
      getPreviousPage();
    }
  };

  return {
    ...storeProps,
    updateIndex,
  };
};

const CarouselControlsContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
  mergeProps,
)(CarouselControlsComponent);

export default CarouselControlsContainer;
