import React from 'react';
import PropTypes from 'prop-types';

import { shortDate } from 'utils/format.utils';

import SdkLogo from 'Icons/SdkLogo.component';
import CreativeFormatList from './CreativeFormatList.component';

const AdSummaryPanelComponent = ({
  adSdks,
  firstSeenDate,
  formats,
  itemId,
  lastSeenDate,
  numCreatives,
  platform,
  totalApps,
}) => {
  const seeSdksStyle = {
    fontSize: '12px',
    marginLeft: '10px',
  };

  const mobileIconStyle = {
    fontSize: '20px',
  };

  return (
    <div className="panel panel-default">
      <div className="panel-heading">
        <strong>Summary</strong>
      </div>
      <div className="panel-body">
        <div className="media">
          <div className="media-body">
            <ul className="list-unstyled list-info ad-intel-list">
              <li>
                <span className="icon fa fa-calendar-check-o" />
                <label>First Seen Ads:</label>
                {shortDate(firstSeenDate)}
              </li>
              <li>
                <span className="icon fa fa-calendar-plus-o" />
                <label>Last Seen Ads:</label>
                {shortDate(lastSeenDate)}
              </li>
              <li>
                <span className="icon fa fa-database" />
                <label>Ad Attribution SDKs:</label>
                {
                  adSdks.length ? adSdks.map(sdk => (
                    <SdkLogo key={sdk.id} platform={platform} sdk={sdk} />
                  )) : <span>None</span>
                }
                <a href={`#/${totalApps ? 'publisher' : 'app'}/${platform}/${itemId}`} style={seeSdksStyle}>
                  See All SDKs
                </a>
              </li>
              {
                totalApps ? (
                  <li>
                    <span className="icon fa fa-mobile" style={mobileIconStyle} />
                    <label>Total Advertising Apps:</label>
                    {totalApps}
                  </li>
                ) : null
              }
              <li>
                <span className="icon fa fa-image" />
                <label>Creative Formats:</label>
                <span>
                  <CreativeFormatList formats={formats} />
                </span>
              </li>
              <li>
                <span className="icon fa fa-bar-chart" />
                <label>Total Creatives:</label>
                {numCreatives}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

AdSummaryPanelComponent.propTypes = {
  adSdks: PropTypes.arrayOf(PropTypes.object),
  firstSeenDate: PropTypes.oneOfType([
    PropTypes.instanceOf(Date),
    PropTypes.string,
  ]).isRequired,
  formats: PropTypes.arrayOf(PropTypes.string).isRequired,
  itemId: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
  ]).isRequired,
  lastSeenDate: PropTypes.oneOfType([
    PropTypes.instanceOf(Date),
    PropTypes.string,
  ]).isRequired,
  numCreatives: PropTypes.number.isRequired,
  platform: PropTypes.string.isRequired,
  totalApps: PropTypes.number,
};

AdSummaryPanelComponent.defaultProps = {
  adSdks: [],
  totalApps: 0,
};

export default AdSummaryPanelComponent;
