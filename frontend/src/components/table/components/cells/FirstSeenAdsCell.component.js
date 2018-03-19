import React from 'react';
import PropTypes from 'prop-types';
import { longDate } from 'utils/format.utils';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import SmallIcon from 'Icons/SmallIcon';

const FirstSeenAdsCell = ({
  app: {
    first_seen_ads_date,
    ad_summaries,
  },
}) => {
  if (!ad_summaries || ad_summaries.length < 2) {
    return <span>{longDate(first_seen_ads_date)}</span>;
  }

  const popover = (
    <Popover id="popover-trigger-hover-focus">
      <ul className="international-data">
        {ad_summaries.map(summary => (
          <li>
            <SmallIcon src={`images/${summary.ad_network}.png`} />
            {' '}
            <span>{longDate(summary.first_seen_ads_date)}</span>
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
            {longDate(first_seen_ads_date)}
          </span>
        </div>
      </OverlayTrigger>
    </div>
  );
};

FirstSeenAdsCell.propTypes = {
  app: PropTypes.shape({
    first_seen_ads_date: PropTypes.string,
    ad_summaries: PropTypes.array,
  }).isRequired,
};

export default FirstSeenAdsCell;
