import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import { capitalize, timeAgo } from 'utils/format.utils';
import { filterRankings } from 'utils/explore/general.utils';

const NewcomerCell = ({
  app: {
    id,
    platform,
    newcomers,
  },
  rest: {
    getCategoryById,
    currentRankingsCountries,
  },
}) => {
  if (!newcomers || newcomers.length === 0) return <span className="invalid">No data</span>;
  newcomers = filterRankings(newcomers, currentRankingsCountries, 'date');

  const baseChart = newcomers[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={newcomers.length > 1 ? 'tooltip-item' : ''}>
        {`Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: ${timeAgo(baseChart.date)}`}
      </span>
    </span>
  );

  if (newcomers.length === 1) return base;

  const popover = (
    <Popover id="popover-trigger-hover-focus" bsClass="rankings-popover popover">
      <ul className="international-data">
        {newcomers.map(chart => (
          <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`} className="rank-change-li">
            <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
            {`Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: ${timeAgo(chart.date)}`}
          </li>
        ))}
      </ul>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" trigger={['hover', 'focus']}>
        {base}
      </OverlayTrigger>
    </div>
  );
};

NewcomerCell.propTypes = {
  app: PropTypes.shape({
    platform: PropTypes.string,
    rankings: PropTypes.shape({
      charts: PropTypes.array,
    }),
  }).isRequired,
  rest: PropTypes.shape({
    getCategoryById: PropTypes.func,
    currentRankingsCountries: PropTypes.string,
  }).isRequired,
};

export default NewcomerCell;
