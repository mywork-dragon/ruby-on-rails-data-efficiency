import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import { capitalize } from 'utils/format.utils';
import { filterRankings } from 'utils/explore/general.utils';

const RankCell = ({
  app: {
    id,
    platform,
    rankings: { charts },
  },
  rest: {
    getCategoryById,
    currentRankingsCountries,
  },
}) => {
  if (!charts || charts.length === 0) {
    return <span className="invalid">No rankings data</span>;
  }

  charts = filterRankings(charts, currentRankingsCountries, 'rank');

  const baseChart = charts[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={charts.length > 1 ? 'tooltip-item' : ''}>
        {`Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: ${baseChart.rank}`}
      </span>
    </span>
  );

  if (charts.length === 1) return base;

  const popover = (
    <Popover id="popover-trigger-hover-focus" bsClass="rankings-popover popover">
      <ul className="international-data">
        {charts.map(chart => (
          <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`}>
            <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
            {`Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: ${chart.rank}`}
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

RankCell.propTypes = {
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

export default RankCell;
