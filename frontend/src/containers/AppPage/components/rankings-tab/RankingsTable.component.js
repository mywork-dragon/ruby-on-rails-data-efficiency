import React from 'react';
import PropTypes from 'prop-types';
import { LineChart } from 'react-chartkick';
import { capitalize } from 'utils/format.utils';

const RankingsTable = ({
  chartData,
  isChartDataLoaded,
  isChartDataLoading,
  requestChartData,
  getCategoryNameById,
  colors,
}) => {
  if (!isChartDataLoaded && !isChartDataLoading) requestChartData();

  const data = chartData.map((x) => {
    const result = {
      name: `${x.country_code} ${capitalize(x.rank_type)} ${getCategoryNameById(x.category)}`,
      data: {},
    };

    x.ranks.forEach((rank) => {
      result.data[rank[0]] = rank[1];
    });

    return result;
  });

  return (
    <div>
      <LineChart
        data={data}
        library={{
          vAxis: {
            direction: -1,
            format: '0',
            viewWindow: {
              min: 1,
            },
          },
          pointsVisible: false,
          focusTarget: 'category',
          legend: { position: 'none' },
          colors,
        }}
      />
    </div>
  );
};

RankingsTable.propTypes = {
  chartData: PropTypes.arrayOf(PropTypes.object).isRequired,
  isChartDataLoaded: PropTypes.bool.isRequired,
  isChartDataLoading: PropTypes.bool.isRequired,
  requestChartData: PropTypes.func.isRequired,
  getCategoryNameById: PropTypes.func.isRequired,
  colors: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export default RankingsTable;
