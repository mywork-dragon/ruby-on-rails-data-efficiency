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
  getCategoryById,
  currentRankingsCountries,
}) => {
  if (!charts || charts.length === 0) {
    return <span className="invalid">No rankings data</span>;
  }

  const filtered = filterRankings(charts, currentRankingsCountries, 'rank');

  const baseChart = filtered[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={filtered.length > 1 ? 'dotted-link' : ''}>
        {`${baseChart.country} Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: ${baseChart.rank}`}
      </span>
    </span>
  );

  if (filtered.length === 1) return base;

  const popover = (
    <Popover id="popover-trigger-click-root-close" bsClass="rankings-popover popover">
      <div className="rankings-scroll">
        <ul className="international-data">
          {filtered.map(chart => (
            <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`}>
              <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
              {`${chart.country} Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: ${chart.rank}`}
            </li>
          ))}
        </ul>
      </div>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger container={document.querySelector('.explore-page')} overlay={popover} placement="left" rootClose trigger={['click']}>
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
  getCategoryById: PropTypes.func.isRequired,
  currentRankingsCountries: PropTypes.string.isRequired,
};

export default RankCell;
