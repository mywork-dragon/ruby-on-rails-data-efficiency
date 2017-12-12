import React from 'react';
import PropTypes from 'prop-types';

import { shortDate } from 'utils/format.utils';

import SdkLogo from 'components/icons/sdkLogo.component';
import CreativeFormatList from '../shared/creative-format-list/CreativeFormatList.component';

const AdSummaryPanel = (props) => {
  const {
    firstSeenDate,
    lastSeenDate,
    adSdks,
    platform,
    formats,
    numCreatives,
    itemId,
    itemType,
    totalApps,
  } = props;

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
                    <SdkLogo sdk={sdk} platform={platform} key={sdk.id} />
                  )) : <span>None</span>
                }
                {
                  itemType === 'app' ? (
                    <a href={`#/app/${platform}/${itemId}`} style={seeSdksStyle}>
                      See All SDKs
                    </a>
                  ) : (
                    <a href={`#/publisher/${platform}/${itemId}`} style={seeSdksStyle}>
                      See All SDKs
                    </a>
                  )
                }
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

AdSummaryPanel.propTypes = {
  firstSeenDate: PropTypes.string.isRequired,
  lastSeenDate: PropTypes.string.isRequired,
  adSdks: PropTypes.arrayOf(PropTypes.object),
  platform: PropTypes.string.isRequired,
  formats: PropTypes.arrayOf(PropTypes.string).isRequired,
  numCreatives: PropTypes.number.isRequired,
  itemId: PropTypes.number.isRequired,
  itemType: PropTypes.string.isRequired,
  totalApps: PropTypes.number,
};

AdSummaryPanel.defaultProps = {
  adSdks: [],
  totalApps: 0,
};

export default AdSummaryPanel;
