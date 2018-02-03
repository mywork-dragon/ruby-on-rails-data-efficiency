import React from 'react';
import PropTypes from 'prop-types';

import { longDate } from 'utils/format.utils';
import NoCreativesPopover from './NoCreativesPopover.component';
import CreativeFormatList from './CreativeFormatList.component';
import NetworkName from './NetworkName.component';

const AdNetworkPanelComponent = ({ networks }) => (
  <div className="panel panel-default">
    <div className="panel-heading"><strong>Ad Networks</strong></div>
    <div className="panel-body">
      <div className="media">
        <div className="media-body">
          <table className="table ad-network-table">
            <thead>
              <tr>
                <th>Network</th>
                <th>First Seen</th>
                <th>Last Seen</th>
                <th>Formats</th>
                <th>Total Creatives</th>
              </tr>
            </thead>
            <tbody>
              {
                  networks.map(source => (
                    <tr key={source.id}>
                      <td className="creative-cell">
                        <NetworkName network={source} />
                      </td>
                      <td className="creative-cell">
                        {longDate(source.first_seen_ads_date)}
                      </td>
                      <td className="creative-cell">
                        {longDate(source.last_seen_ads_date)}
                      </td>
                      <td>
                        <CreativeFormatList formats={source.creative_formats} />
                      </td>
                      <td>
                        {source.number_of_creatives}
                          &nbsp;
                        {source.number_of_creatives === 0 ? <NoCreativesPopover /> : ''}
                      </td>
                    </tr>
                    ))
                }
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
);

AdNetworkPanelComponent.propTypes = {
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
};

export default AdNetworkPanelComponent;
