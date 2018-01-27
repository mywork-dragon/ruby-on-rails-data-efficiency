import React from 'react';
import PropTypes from 'prop-types';

import CreativeMixpanelService from 'Mixpanel/creative.mixpanel';
import AdNetworkCellContainer from 'Table/containers/AdNetworkCell.container';
import { longDate, capitalize } from 'utils/format.utils';
import LoadingSpinner from 'Messaging/LoadingSpinner.component';
import TableHeader from 'Table/components/TableHeader.component';
import ThumbnailCell from './ThumbnailCell.component';
import AppLogo from './AppLogo.component';
import PaginationContainer from '../containers/CreativePagination.container';

const CreativeTableComponent = ({
  activeFormats,
  activeIndex,
  activeNetworks,
  apps,
  fetching,
  requestCreatives,
  itemId,
  networks,
  pageNum,
  pageSize,
  platform,
  results,
  showApps,
  totalCount,
  updateIndex,
}) => {
  const columnHeaders = [
    'Preview',
    'Networks',
    'First Seen',
    'Last Seen',
    'Format',
  ];

  if (showApps) { columnHeaders.splice(4, 0, 'App'); }

  if (fetching) {
    return (
      <div className="table-response creative-table">
        <div className="empty-creative-ctnr">
          <LoadingSpinner />
        </div>
      </div>
    );
  }

  const type = showApps ? 'publisher' : 'app';

  const handleCreativeClick = (creative, index) => {
    CreativeMixpanelService(itemId, platform, type).trackCreativeClick(creative);
    updateIndex(index);
  };

  const showPagination = totalCount > pageSize;

  return results.length ? (
    <div>
      <table className="table table-striped responsive table-hover table-bordered">
        <TableHeader headers={columnHeaders} />
        <tbody>
          { results.map((creative, index) => (
            <tr key={creative.url} className={`creative-table-row ${activeIndex === index ? 'active' : ''}`} onClick={() => handleCreativeClick(creative, index)}>
              <ThumbnailCell creative={creative} />
              <td className="creative-cell">
                <AdNetworkCellContainer networks={creative.ad_networks} showName />
              </td>
              <td className="creative-cell">
                {longDate(creative.first_seen_creative_date)}
              </td>
              <td className="creative-cell">
                {longDate(creative.last_seen_creative_date)}
              </td>
              { showApps ? (
                <td className="creative-cell">
                  <AppLogo adIntel app={apps.find(app => parseInt(app.id, 10) === creative.app_id)} platform={platform} />
                </td>
              ) : null}
              <td className="creative-cell">
                {capitalize(creative.format)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      { showPagination ? (
        <PaginationContainer
          activeFormats={activeFormats}
          activeNetworks={activeNetworks}
          itemId={itemId}
          pageNum={pageNum}
          pageSize={pageSize}
          platform={platform}
          requestCreatives={requestCreatives}
          resultsCount={totalCount}
          type={type}
        />
      ) : null }
    </div>
  ) : (
    <div className="empty-data-ctnr">
      No Results
    </div>
  );
};

CreativeTableComponent.propTypes = {
  activeFormats: PropTypes.arrayOf(PropTypes.string).isRequired,
  activeIndex: PropTypes.number.isRequired,
  activeNetworks: PropTypes.arrayOf(PropTypes.string).isRequired,
  apps: PropTypes.arrayOf(PropTypes.object).isRequired,
  fetching: PropTypes.bool.isRequired,
  requestCreatives: PropTypes.func.isRequired,
  itemId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
  pageNum: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  platform: PropTypes.string.isRequired,
  results: PropTypes.arrayOf(PropTypes.object).isRequired,
  showApps: PropTypes.bool,
  totalCount: PropTypes.number.isRequired,
  updateIndex: PropTypes.func.isRequired,
};

CreativeTableComponent.defaultProps = {
  showApps: false,
};

export default CreativeTableComponent;
