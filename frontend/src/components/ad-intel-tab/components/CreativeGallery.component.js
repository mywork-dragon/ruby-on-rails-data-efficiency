import React from 'react';
import PropTypes from 'prop-types';

import NoDataMessage from 'Messaging/NoData.component';
import LoadingSpinner from 'Messaging/LoadingSpinner.component';
import FilterButton from 'Buttons/FilterButton.component';
import ActiveCreativeComponent from '../components/ActiveCreative.component';
import CarouselControlsContainer from '../containers/CarouselControls.container';
import CreativeTableComponent from '../components/CreativeTable.component';
import CreativeFilterComponent from '../components/CreativeFilters.component';

const CreativeGalleryComponent = ({
  activeCreative,
  activeFormats,
  activeIndex,
  activeNetworks,
  advertisingApps,
  fetching,
  formats,
  getCreatives,
  id,
  isLoaded,
  networks,
  hasCreatives,
  pageNum,
  pageSize,
  platform,
  requestCreatives,
  results,
  showApps,
  toggleFilter,
  totalCount,
  updateIndex,
}) => {
  if (!isLoaded && hasCreatives && !fetching) {
    getCreatives();
  }

  return (
    <div className="panel panel-default">
      <div className="panel-heading">
        <strong>Creatives</strong>
      </div>
      {
        isLoaded ? (
          <div className="panel-body">
            {
              !hasCreatives ? (
                <NoDataMessage>
                  No Creatives
                </NoDataMessage>
              ) : (
                <div>
                  <div className="col-md-6">
                    <div>
                      {
                        totalCount <= 1 && activeCreative.format !== 'html' ? (
                          <div className="single-creative-pad" />
                        ) : null
                      }
                      <CarouselControlsContainer
                        activeIndex={activeIndex}
                        currentSize={results.length}
                        format={activeCreative.format}
                        formats={activeFormats}
                        networks={activeNetworks}
                        pageNum={pageNum}
                        pageSize={pageSize}
                        requestCreatives={requestCreatives}
                        resultsCount={totalCount}
                        updateIndex={updateIndex}
                      />
                      <ActiveCreativeComponent
                        apps={advertisingApps}
                        creative={activeCreative}
                        platform={platform}
                        resultsCount={totalCount}
                        showApp={showApps}
                      />
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="creative-gallery-filters">
                      <CreativeFilterComponent
                        activeFilters={activeFormats}
                        filters={formats}
                        label="FORMATS"
                        toggleFilter={toggleFilter}
                        type="activeFormats"
                      />
                      <CreativeFilterComponent
                        activeFilters={activeNetworks}
                        filters={networks}
                        label="NETWORKS"
                        toggleFilter={toggleFilter}
                        type="activeNetworks"
                      />
                      <FilterButton className="btn btn-primary" onClick={() => getCreatives()}>Filter</FilterButton>
                    </div>
                    <CreativeTableComponent
                      activeFormats={activeFormats}
                      activeIndex={activeIndex}
                      activeNetworks={activeNetworks}
                      apps={advertisingApps}
                      fetching={fetching}
                      itemId={id}
                      networks={networks}
                      pageNum={pageNum}
                      pageSize={pageSize}
                      platform={platform}
                      requestCreatives={requestCreatives}
                      results={results}
                      showApps={showApps}
                      totalCount={totalCount}
                      updateIndex={updateIndex}
                    />
                  </div>
                </div>
              )
            }
          </div>
        ) : (
          <div className="panel-body">
            <div className="empty-creative-ctnr">
              <LoadingSpinner />
            </div>
          </div>
        )
      }
    </div>
  );
};

CreativeGalleryComponent.propTypes = {
  activeCreative: PropTypes.shape({
    last_seen_creative_date: PropTypes.date,
    app_identifier: PropTypes.string,
    format: PropTypes.string,
    url: PropTypes.string,
  }),
  activeFormats: PropTypes.arrayOf(PropTypes.string).isRequired,
  activeIndex: PropTypes.number.isRequired,
  activeNetworks: PropTypes.arrayOf(PropTypes.string).isRequired,
  advertisingApps: PropTypes.arrayOf(PropTypes.object),
  fetching: PropTypes.bool.isRequired,
  formats: PropTypes.arrayOf(PropTypes.string).isRequired,
  getCreatives: PropTypes.func.isRequired,
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  isLoaded: PropTypes.bool.isRequired,
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
  hasCreatives: PropTypes.bool.isRequired,
  pageNum: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  platform: PropTypes.string.isRequired,
  requestCreatives: PropTypes.func.isRequired,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  showApps: PropTypes.bool,
  toggleFilter: PropTypes.func.isRequired,
  totalCount: PropTypes.number.isRequired,
  updateIndex: PropTypes.func.isRequired,
};

CreativeGalleryComponent.defaultProps = {
  activeCreative: {},
  advertisingApps: [],
  showApps: false,
};

export default CreativeGalleryComponent;
