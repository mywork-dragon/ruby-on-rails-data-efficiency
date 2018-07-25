import React from 'react';
import PropTypes from 'prop-types';
import moment from 'moment';
import { Chart } from 'react-google-charts';
import { capitalize } from 'utils/format.utils';

const RankingsChart = ({
  chartData,
  colors,
  getCategoryNameById,
}) => {
  let maxRank = 0;
  const data = [];
  const columns = [{ type: 'datetime', label: 'Date' }];

  chartData.forEach((x, i) => {
    const name = `${x.country} ${capitalize(x.rank_type)} ${getCategoryNameById(x.category)}`;
    columns.push({ type: 'number', label: name });

    x.ranks.forEach((rank, idx) => {
      if (i === 0) {
        data.push([moment(rank[0]).toDate()]);
      }
      data[idx].push(rank[1]);
      if (rank[1]) maxRank = Math.max(maxRank, rank[1]);
    });
  });

  const ticks = [1];
  const multiplier = maxRank < 100 ? 10 : 100;
  const x = Math.floor((maxRank + multiplier) / multiplier);
  for (let i = 1; i <= x; i++) {
    ticks.push(i * multiplier);
  }

  const minDate = data[0][0];
  const maxDate = data[data.length - 1][0];

  return (
    <div>
      <Chart
        chartType="LineChart"
        columns={columns}
        getChartWrapper={(wrapper) => {
          const formatter = new window.google.visualization.DateFormat({ pattern: 'MMM dd, yyyy' });
          const dataTable = wrapper.getDataTable();
          formatter.format(dataTable, 0);
          wrapper.setDataTable(dataTable);
          wrapper.draw();
        }}
        height="500px"
        options={{
          vAxis: {
            direction: -1,
            minorGridlines: {
              count: maxRank < 100 ? 0 : 1,
            },
            viewWindow: {
              min: 1,
            },
            ticks,
          },
          hAxis: {
            gridlines: {
              color: '#ccc',
              count: 8,
            },
            minorGridlines: {
              count: 1,
            },
            viewWindow: {
              min: minDate,
              max: maxDate,
            },
          },
          chartArea: {
            width: '90%',
            height: '75%',
          },
          pointsVisible: false,
          focusTarget: 'category',
          colors,
          legend: {
            alignment: 'center',
            position: 'top',
          },
          fontName: 'Open Sans',
          fontSize: 12,
        }}
        rows={data}
        width="100%"
      />
    </div>
  );
};

RankingsChart.propTypes = {
  chartData: PropTypes.arrayOf(PropTypes.object).isRequired,
  colors: PropTypes.arrayOf(PropTypes.string).isRequired,
  getCategoryNameById: PropTypes.func.isRequired,
};

export default RankingsChart;
