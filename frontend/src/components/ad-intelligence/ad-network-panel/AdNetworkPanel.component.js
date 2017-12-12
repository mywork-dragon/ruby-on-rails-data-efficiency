import React from 'react';
import PropTypes from 'prop-types';

import { shortDate } from 'utils/format.utils';
import NoCreativesPopover from '../shared/NoCreativesPopover.component';
import CreativeFormatList from '../shared/creative-format-list/CreativeFormatList.component';
import NetworkName from '../shared/NetworkName.component';

const AdNetworkPanel = ({ networks }) => (
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
                        <NetworkName network={source} a />
                      </td>
                      <td className="creative-cell">
                        {shortDate(source.first_seen_ads_date)}
                      </td>
                      <td className="creative-cell">
                        {shortDate(source.last_seen_ads_date)}
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

AdNetworkPanel.propTypes = {
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
};

export default AdNetworkPanel;
