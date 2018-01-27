import React from 'react';
import PropTypes from 'prop-types';

import NoDataMessage from 'Messaging/NoData.component';
import LoadingSpinner from 'Messaging/LoadingSpinner.component';
import Table from 'Table/Table.component';
import AdNetworkPanelComponent from './components/AdNetworkPanel.component';
import AdSummaryPanelComponent from './components/AdSummaryPanel.component';
import CreativeGalleryContainer from './containers/CreativeGallery.container';

const AdIntelTabComponent = ({
  adIntel,
  results,
  isLoaded,
  itemId,
  loadError,
  noData,
  platform,
  requestInfo,
  requestCreatives,
  selectedItems,
  showAppsTable,
  toggleAll,
  toggleItem,
  toggleFilter,
  type,
  updateIndex,
}) => {
  if (loadError) {
    return (
      <NoDataMessage>
        Whoops! There was an error getting ad data for this {type}. Please try again.
      </NoDataMessage>
    );
  } else if (!isLoaded) {
    requestInfo();

    return (
      <div className="ad-intel-spinner-ctnr">
        <LoadingSpinner />
      </div>
    );
  } else if (isLoaded && noData) {
    return (
      <NoDataMessage>
        No Ad Data
      </NoDataMessage>
    );
  }

  const tableOptions = adIntel.info.tableOptions;

  return (
    <div>
      <div className="ad-intel-row">
        <div className="row-panel">
          <AdNetworkPanelComponent networks={adIntel.info.ad_networks} />
        </div>
        <div className="row-panel">
          <AdSummaryPanelComponent
            adSdks={adIntel.info.ad_attribution_sdks}
            firstSeenDate={adIntel.info.first_seen_ads_date}
            formats={adIntel.info.creative_formats}
            itemId={itemId}
            lastSeenDate={adIntel.info.last_seen_ads_date}
            numCreatives={adIntel.info.number_of_creatives}
            platform={platform}
            totalApps={adIntel.info.total_apps}
          />
        </div>
      </div>
      <div className="col-md-12">
        <CreativeGalleryContainer
          adIntel={adIntel}
          itemId={itemId}
          platform={platform}
          requestCreatives={requestCreatives}
          showApps={showAppsTable}
          toggleFilter={toggleFilter}
          updateIndex={updateIndex}
        />
        {
          showAppsTable ? (
            <div className="row companyPageRow">
              <Table
                defaultSort={tableOptions.defaultSort}
                headers={tableOptions.appTableHeaders}
                results={results}
                selectedItems={selectedItems}
                showControls={false}
                title={tableOptions.tableHeader}
                toggleAll={toggleAll}
                toggleItem={toggleItem}
                totalCount={results.length}
              />
            </div>
          ) : null
        }
      </div>
    </div>
  );
};

AdIntelTabComponent.propTypes = {
  adIntel: PropTypes.shape({
    info: PropTypes.object,
    creatives: PropTypes.object,
  }),
  results: PropTypes.arrayOf(PropTypes.object),
  isLoaded: PropTypes.bool.isRequired,
  itemId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  loadError: PropTypes.bool,
  noData: PropTypes.bool,
  platform: PropTypes.string.isRequired,
  requestCreatives: PropTypes.func.isRequired,
  requestInfo: PropTypes.func.isRequired,
  selectedItems: PropTypes.arrayOf(PropTypes.object),
  showAppsTable: PropTypes.bool,
  toggleAll: PropTypes.func,
  toggleItem: PropTypes.func,
  toggleFilter: PropTypes.func.isRequired,
  type: PropTypes.string,
  updateIndex: PropTypes.func.isRequired,
};

AdIntelTabComponent.defaultProps = {
  adIntel: {},
  results: [],
  loadError: false,
  noData: true,
  selectedItems: [],
  showAppsTable: false,
  toggleAll: null,
  toggleItem: null,
  type: 'app',
};

export default AdIntelTabComponent;
