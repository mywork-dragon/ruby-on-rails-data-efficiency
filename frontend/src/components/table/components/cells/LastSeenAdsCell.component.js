import React from 'react';
import PropTypes from 'prop-types';
import { longDate } from 'utils/format.utils';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import SmallIcon from 'Icons/SmallIcon';

const LastSeenAdsCell = ({
  app: {
    last_seen_ads_date,
    ad_summaries,
  },
}) => {
  if (!last_seen_ads_date && (!ad_summaries || ad_summaries.length === 0)) {
    return <span className="invalid">No ad data</span>;
  } else if (!ad_summaries || ad_summaries.length < 2) {
    return <span>{longDate(last_seen_ads_date)}</span>;
  }

  const popover = (
    <Popover id="popover-trigger-hover-focus">
      <ul className="international-data">
        {ad_summaries.map(summary => (
          <li key={`ad-network ${summary.ad_network}`}>
            <SmallIcon src={`images/${summary.ad_network}.png`} />
            {' '}
            <span>{longDate(summary.last_seen_ads_date)}</span>
          </li>
        ))}
      </ul>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" trigger={['hover', 'focus']}>
        <div>
          <span className="tooltip-item">
            {longDate(last_seen_ads_date)}
          </span>
        </div>
      </OverlayTrigger>
    </div>
  );
};

LastSeenAdsCell.propTypes = {
  app: PropTypes.shape({
    last_seen_ads_date: PropTypes.oneOfType([PropTypes.string, PropTypes.instanceOf(Date)]),
    ad_summaries: PropTypes.array,
  }).isRequired,
};

export default LastSeenAdsCell;
