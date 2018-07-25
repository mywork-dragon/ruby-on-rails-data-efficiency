import moment from 'moment';

export const googleChartColors = [
  '#3366cc',
  '#dc3912',
  '#ff9900',
  '#109618',
  '#990099',
  '#0099c6',
  '#dd4477',
  '#66aa00',
  '#b82e2e',
  '#316395',
  '#994499',
  '#22aa99',
  '#aaaa11',
  '#6633cc',
  '#e67300',
  '#8b0707',
  '#651067',
  '#329262',
  '#5574a6',
  '#3b3eac',
  '#b77322',
  '#16d620',
  '#b91383',
  '#f4359e',
  '#9c5935',
  '#a9c413',
  '#2a778d',
  '#668d1c',
  '#bea413',
  '#0c5922',
  '#743411',
];

export const getChartColor = idx => (googleChartColors[idx] ? googleChartColors[idx] : googleChartColors[idx - googleChartColors.length - 1]);

export const generateDateList = (startDate, endDate = new Date()) => {
  const dates = [];
  const currDate = moment(startDate).startOf('day');
  const lastDate = moment(endDate).startOf('day');

  dates.push(currDate.clone().toDate());

  while (currDate.add(1, 'days').diff(lastDate) < 0) {
    dates.push(currDate.clone().toDate());
  }

  dates.push(currDate.toDate());

  return dates;
};

export const fillRankingsGaps = (ranks, dateRange) => {
  const dates = generateDateList(moment().subtract(dateRange, 'days')).map(x => x.toISOString().slice(0, 10));

  const ranksByDate = {};
  ranks.forEach((rank) => {
    ranksByDate[rank[0]] = rank[1];
  });

  let mapped = {};
  dates.forEach((date) => { mapped[date] = ranksByDate[date]; });

  mapped = Object.entries(mapped);
  mapped = mapped.map((x, i) => {
    const [date, rank] = x;
    const prevRank = mapped[i - 1] ? mapped[i - 1][1] : null;
    const nextRank = mapped[i + 1] ? mapped[i + 1][1] : null;
    if (!rank && prevRank && nextRank) {
      return [date, prevRank];
    }

    return x;
  });

  return mapped;
};
