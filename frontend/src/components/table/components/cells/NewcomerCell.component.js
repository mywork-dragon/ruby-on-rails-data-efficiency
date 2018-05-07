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
    currentSort,
  },
}) => {
  if (!newcomers || newcomers.length === 0) return <span className="invalid">No data</span>;
  const filtered = filterRankings(newcomers, currentRankingsCountries, 'date', currentSort);

  const baseChart = filtered[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={filtered.length > 1 ? 'dotted-link' : ''}>
        {`${baseChart.country} Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: ${timeAgo(baseChart.date)}`}
      </span>
    </span>
  );

  if (filtered.length === 1) return base;

  const popover = (
    <Popover id="popover-trigger-hover-focus" bsClass="rankings-popover popover">
      <div className="rankings-scroll">
        <ul className="international-data">
          {filtered.map(chart => (
            <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`} className="rank-change-li">
              <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
              {`${chart.country} Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: ${timeAgo(chart.date)}`}
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
