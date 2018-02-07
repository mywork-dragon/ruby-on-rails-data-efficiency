import React from 'react';
import PropTypes from 'prop-types';

import { capitalize, longDate } from 'utils/format.utils';

import AdNetworkLogo from 'Icons/AdNetworkLogo.component';
import SmallIcon from 'Icons/SmallIcon';
import ActiveCreativePreviewComponent from './ActiveCreativePreview.component';
import NetworkName from './NetworkName.component';

const ActiveCreativeComponent = ({
  apps,
  creative,
  platform,
  resultsCount,
  showApp,
}) => {
  if (resultsCount === 0) {
    return (
      <div>
        <div className="single-creative-pad" />
        <div className="active-creative-media-ctnr">
          <div className="empty-data-ctnr">
            <i className="fa fa-picture-o" />
          </div>
        </div>
      </div>
    );
  }

  const seenOnce = creative.first_seen_creative_date === creative.last_seen_creative_date;
  const app = creative ? apps.find(x => parseInt(x.id, 10) === creative.app_id) : {};

  return (
    <div>
      <ActiveCreativePreviewComponent format={creative.format} url={creative.url} />
      <ul className="list-unstyled list-info">
        <li>
          <span className="icon fa fa-cloud" />
          <label>Network:</label>
          { creative.ad_networks.length === 1 ? <NetworkName network={creative.ad_networks[0]} /> :
            creative.ad_networks.map(network => <AdNetworkLogo key={network.id} {...network} />)
          }
        </li>
        {
          showApp &&
          <li>
            <span className={`icon fa fa-fw ${platform === 'ios' ? 'fa-apple' : 'fa-android'}`} />
            <label>App:</label>
            <a href={`#/app/${platform}/${app.id}/ad-intelligence`}>
              <SmallIcon src={app.icon} />
              {app.name}
            </a>
          </li>
        }
        <li>
          <span className="icon fa fa-image" />
          <label>Format:</label>
          {capitalize(creative.format)}
        </li>
        <li>
          <span className="icon fa fa-calendar-check-o" />
          <label>{seenOnce ? 'Date Seen:' : 'First Seen'}</label>
          {longDate(creative.first_seen_creative_date)}
        </li>
        { seenOnce ? null : (
          <div>
            <li>
              <span className="icon fa fa-calendar-plus-o" />
              <label>Last Seen:</label>
              {longDate(creative.last_seen_creative_date)}
            </li>
            <li>
              <span className="icon fa fa-bar-chart" />
              <label>Times Seen:</label>
              {creative.count}
            </li>
          </div>
        )}
      </ul>
    </div>
  );
};

ActiveCreativeComponent.propTypes = {
  apps: PropTypes.arrayOf(PropTypes.object),
  creative: PropTypes.shape({
    last_seen_creative_date: PropTypes.date,
    app_identifier: PropTypes.string,
    format: PropTypes.string,
    url: PropTypes.string,
  }),
  platform: PropTypes.string.isRequired,
  resultsCount: PropTypes.number.isRequired,
  showApp: PropTypes.bool,
};

ActiveCreativeComponent.defaultProps = {
  apps: [],
  creative: {},
  showApp: false,
};

export default ActiveCreativeComponent;
